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
git_dir=$(git rev-parse --git-dir)
report_dir="$git_dir/jj-reviews"
script_dir=$(cd "$(dirname "$0")" && pwd)
schema="$script_dir/review-schema.json"
report="$report_dir/${change_id}-${commit_id:0:12}.json"
diff_file="$report_dir/${change_id}-${commit_id:0:12}.diff"
execution_log="$report_dir/${change_id}-${commit_id:0:12}.exec.log"
umask 077
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

# Capture the exact diff the reviewed commit introduces and feed it to Codex via
# stdin, so the review is bounded to that diff instead of Codex re-deriving it
# with git and exploring the wider repo. This keeps the review native to jj and
# independent of whether the commit is visible to a colocated git. Extra context
# lines reduce the need to reopen files; --ignore-working-copy avoids a fresh
# snapshot that could diverge from the pinned commit.
if ! jj diff -r "$commit_id" --git --context 8 --ignore-working-copy >"$diff_file"; then
  echo "review gate failed: could not produce diff for $commit_id" >&2
  echo "bookmark was not changed" >&2
  exit 70
fi

prompt="Perform an independent security, correctness, and maintainability review of the code diff provided in the <stdin> block. Review only behavior introduced or changed by that diff. You may read changed files and directly affected callers, callees, contracts, configuration, and tests when needed to trace a suspected issue end-to-end, but do not explore unrelated parts of the repository. Do not modify any files. Report every high-confidence actionable correctness bug, regression, concurrency issue, error-handling defect, security vulnerability, feature-gate or internal-only leak, breaking developer-workflow change, and material test gap. Developer-workflow regressions include breaking changes to secrets or environment-variable handling, ports, required setup scripts, and normal build or run procedures. Trace cross-module effects far enough to establish how changed behavior reaches callers or users. Do not report clearly intentional, well-contained behavior changes merely because they break prior behavior; report unintended secondary effects or materially broader impact. Resolve accessible uncertainty before reporting, and do not file conditional speculation about code you can inspect. Calibrate severity to demonstrated impact and reachability; do not inflate hypothetical or low-impact issues. Use these severity levels consistently: critical means a confirmed, realistically reachable issue that can cause data loss or corruption, authentication or authorization bypass, sensitive-data exposure, remote code execution, catastrophic service outage, or broad failure of core functionality with no practical workaround; high means a confirmed major security or correctness regression with substantial but non-catastrophic impact or a practical workaround; medium means a confirmed limited-condition or edge-path defect whose impact is recoverable or readily avoided; low means a smaller but actionable defect or a material maintainability, developer-experience, or test gap. Never assign critical to speculation, file size alone, abstraction quality alone, or a test gap alone. Also report high-confidence material maintainability regressions introduced by the diff, especially accidental branching or state complexity, indirection that does not reduce complexity, a clearly simpler structure that would remove concepts or branches, logic outside its canonical owner, duplication of a canonical helper, unclear type or API boundaries, lost module cohesion, unnecessarily sequential orchestration, or non-atomic related updates. Treat growth of a hand-written source or test file, including crossing 1000 lines, only as evidence of lost cohesion and never as a finding by itself. Do not apply this heuristic to documentation, generated or vendored code, lockfiles, snapshots, or data and fixture files. Prefer a small number of high-conviction actionable findings over style nits or speculative redesigns. For each maintainability finding, explain the complexity introduced and a concrete simpler direction while respecting the change's scope and avoiding unrelated refactors. Return an empty findings array only when there are no actionable problems. Use an empty file string and line 0 when a finding has no precise source location."

echo "Running Codex review for change $change_id ($commit_id)..." >&2

# Enforce the wall-clock cap above so a slow or hung Codex run fails cleanly
# instead of hanging the caller. coreutils `timeout` is absent on stock macOS and
# `wait -n` needs bash 4.3+, so use a portable background watchdog: block on the
# review, but SIGTERM it if the watchdog's sleep elapses first.
codex exec \
  --ephemeral \
  --sandbox read-only \
  --color never \
  --output-schema "$schema" \
  --output-last-message "$report" \
  "$prompt" <"$diff_file" >"$execution_log" 2>&1 &
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
  echo "Codex execution log: $execution_log" >&2
  echo "bookmark was not changed" >&2
  exit 70
fi

if ! jq -e '.findings | type == "array"' "$report" >/dev/null; then
  echo "review gate failed: invalid review result in $report" >&2
  echo "Codex execution log: $execution_log" >&2
  echo "bookmark was not changed" >&2
  exit 65
fi

# Codex echoes its prompt and stdin diff in the execution transcript. Keep that
# transcript out of the caller's context, and discard it once the structured
# report proves the review completed successfully.
rm -f "$execution_log"

finding_count=$(jq '.findings | length' "$report")
critical_count=$(jq '[.findings[] | select(.severity == "critical")] | length' "$report")
if (( finding_count > 0 )); then
  echo >&2
  echo "Codex review returned $finding_count finding(s):" >&2
  jq -r '.findings[] | "[\(.severity | ascii_upcase)] \(.title)\n\(if .file != "" then "  at \(.file):\(.line)\n" else "" end)  \(.description)\n"' "$report" >&2
else
  echo "Codex review returned no findings." >&2
fi

if (( critical_count > 0 )); then
  echo "Review gate failed: $critical_count critical finding(s)." >&2
  echo "Review report: $report" >&2
  echo "bookmark was not changed" >&2
  exit 3
fi

echo "Review gate passed: no critical findings." >&2

# Pin the bookmark to the exact commit that was reviewed, not a re-resolved
# revision, so a working-copy snapshot during review cannot retarget it to an
# unreviewed commit. --ignore-working-copy avoids taking a fresh snapshot here.
jj bookmark set "$bookmark" -r "$commit_id" --ignore-working-copy
echo "Review report: $report" >&2
