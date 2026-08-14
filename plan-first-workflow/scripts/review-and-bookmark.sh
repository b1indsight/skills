#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "usage: $0 <bookmark> [revision]" >&2
  exit 64
fi

for command in jj git codex jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "review gate failed: required command not found: $command" >&2
    exit 69
  fi
done

bookmark=$1
revision=${2:-@}
review_remote=${JJ_REVIEW_REMOTE-origin}
if [[ -z "$review_remote" ]]; then
  echo "review gate failed: JJ_REVIEW_REMOTE must not be empty" >&2
  exit 64
fi
workspace_root=$(jj root)
cd "$workspace_root"

# Force jj to snapshot the working copy before resolving the target revision.
jj status >/dev/null

# Resolve the target revision to exactly one commit. A revset that matches
# zero or several commits would otherwise concatenate ids and corrupt the
# review prompt, the report path, and the final bookmark target.
revision_commits=$(jj log -r "$revision" --no-graph --limit 2 -T 'commit_id ++ "\n"')
if [[ -z "$revision_commits" ]]; then
  echo "review gate failed: revision '$revision' resolved to no commits" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi
if [[ "$revision_commits" == *$'\n'* ]]; then
  echo "review gate failed: revision '$revision' must resolve to exactly one commit" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi
commit_id=$revision_commits
change_id=$(jj log -r "$commit_id" --no-graph -T 'change_id.shortest(12)')

# Resolve the previous submitted state without interpolating bookmark or remote
# names as executable revset syntax. The remote bookmark is the normal source of
# truth because a local bookmark follows rewritten commits while its remote
# counterpart remains at the last fetched/pushed state.
escape_revset_string() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  printf '%s' "$value"
}

bookmark_pattern=$(escape_revset_string "$bookmark")
remote_pattern=$(escape_revset_string "$review_remote")
remote_revset="remote_bookmarks(exact:\"$bookmark_pattern\", remote=exact:\"$remote_pattern\")"
base_commits=$(jj log -r "$remote_revset" --no-graph --limit 2 -T 'commit_id ++ "\n"')
base_source="remote bookmark $bookmark@$review_remote"

if [[ -z "$base_commits" ]]; then
  # A first-ever push has no remote bookmark yet. Prefer an existing local
  # bookmark if it still points to the task's prior state; otherwise use the
  # target's single parent. If the local bookmark already points at the target,
  # the previous state is ambiguous, so fail rather than silently under-review.
  local_revset="bookmarks(exact:\"$bookmark_pattern\")"
  local_commits=$(jj log -r "$local_revset" --no-graph --limit 2 -T 'commit_id ++ "\n"')
  if [[ "$local_commits" == *$'\n'* ]]; then
    echo "review gate failed: local bookmark '$bookmark' resolves to multiple commits" >&2
    echo "bookmark was not changed" >&2
    exit 65
  fi
  if [[ -n "$local_commits" ]]; then
    if [[ "$local_commits" == "$commit_id" ]]; then
      echo "review gate failed: no $bookmark@$review_remote state exists and local bookmark '$bookmark' already points to the target" >&2
      echo "cannot determine the previous task state to review from" >&2
      echo "bookmark was not changed" >&2
      exit 65
    fi
    base_commits=$local_commits
    base_source="local bookmark $bookmark"
  else
    base_commits=$(jj log -r "$commit_id-" --no-graph --limit 2 -T 'commit_id ++ "\n"')
    base_source="target parent"
  fi
fi

if [[ -z "$base_commits" ]]; then
  echo "review gate failed: could not determine a previous task state for '$revision'" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi
if [[ "$base_commits" == *$'\n'* ]]; then
  echo "review gate failed: previous task state must resolve to exactly one commit" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi
base_commit=$base_commits
if [[ "$base_commit" == "$commit_id" ]]; then
  echo "review gate failed: target is already at the previous task state; there is no submission diff to review" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi

git_dir=$(git rev-parse --git-dir)
report_dir="$git_dir/jj-reviews"
script_dir=$(cd "$(dirname "$0")" && pwd)
schema="$script_dir/review-schema.json"
report="$report_dir/${change_id}-${base_commit:0:12}-${commit_id:0:12}.json"
diff_file="$report_dir/${change_id}-${base_commit:0:12}-${commit_id:0:12}.diff"
mkdir -p "$report_dir"

# Hard wall-clock cap for the review, in seconds. Override with
# JJ_REVIEW_TIMEOUT_SECONDS; keep it below the tool timeout the caller gives this
# script, or that outer limit fires first with a less clear error.
review_timeout=${JJ_REVIEW_TIMEOUT_SECONDS:-300}
if ! [[ "$review_timeout" =~ ^[1-9][0-9]*$ ]]; then
  echo "review gate failed: JJ_REVIEW_TIMEOUT_SECONDS must be a positive integer of seconds (got '$review_timeout')" >&2
  echo "bookmark was not changed" >&2
  exit 64
fi

# Capture one net diff for the submission batch, from the task's previous
# submitted state to the exact target that will receive the bookmark. Feed it to
# Codex via stdin so the review stays bounded to this batch instead of exploring
# unrelated history. --ignore-working-copy avoids a fresh snapshot that could
# diverge from the pinned target.
if ! jj diff --from "$base_commit" --to "$commit_id" --git --context 8 --ignore-working-copy >"$diff_file"; then
  echo "review gate failed: could not produce diff from $base_commit to $commit_id" >&2
  echo "bookmark was not changed" >&2
  exit 70
fi

prompt="Perform one independent advisory code review of the complete submission-batch diff provided in the <stdin> block. Review only that diff; you may read a changed file's immediately surrounding lines to judge a hunk, but do not explore or read unrelated files elsewhere in the repository. Do not modify any files. Return actionable suggestions for correctness bugs, regressions, concurrency issues, error-handling defects, security issues, and material test gaps. Return an empty findings array only when there are no actionable suggestions. Use an empty file string and line 0 when a suggestion has no precise source location."

echo "Running one Codex review for submission batch $base_commit..$commit_id ($base_source)..." >&2

# Enforce the wall-clock cap above so a slow or hung Codex run fails cleanly
# instead of hanging the caller. coreutils `timeout` is absent on stock macOS and
# `wait -n` needs bash 4.3+, so use a portable background watchdog: block on the
# review, but SIGTERM it if the watchdog's sleep elapses first.
codex exec \
  --ephemeral \
  --sandbox read-only \
  --output-schema "$schema" \
  --output-last-message "$report" \
  "$prompt" <"$diff_file" &
review_pid=$!
( sleep "$review_timeout"; kill -TERM "$review_pid" 2>/dev/null ) &
watchdog_pid=$!

review_status=0
wait "$review_pid" 2>/dev/null || review_status=$?
# Cancel the watchdog if the review finished on its own.
kill -TERM "$watchdog_pid" 2>/dev/null || true
wait "$watchdog_pid" 2>/dev/null || true

if (( review_status != 0 )); then
  if (( review_status == 143 )); then
    echo "review gate failed: Codex review timed out after ${review_timeout}s" >&2
  else
    echo "review gate failed: Codex review did not complete" >&2
  fi
  echo "bookmark was not changed" >&2
  exit 70
fi

if ! jq -e '.findings | type == "array"' "$report" >/dev/null; then
  echo "review gate failed: invalid review result in $report" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi

finding_count=$(jq '.findings | length' "$report")
if (( finding_count > 0 )); then
  echo >&2
  echo "Codex review returned $finding_count suggestion(s) — advisory only, they do not block the push:" >&2
  jq -r '.findings[] | "[\(.severity | ascii_upcase)] \(.title)\n\(if .file != "" then "  at \(.file):\(.line)\n" else "" end)  \(.description)\n"' "$report" >&2
  echo "Full review: $report" >&2
else
  echo "Codex review returned no suggestions." >&2
fi

# Pin the bookmark to the exact commit that was reviewed, not a re-resolved
# revision, so a working-copy snapshot during review cannot retarget it to an
# unreviewed commit. --ignore-working-copy avoids taking a fresh snapshot here.
jj bookmark set "$bookmark" -r "$commit_id" --ignore-working-copy
echo "Review report: $report" >&2
