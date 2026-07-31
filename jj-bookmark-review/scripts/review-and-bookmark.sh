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

change_id=$(jj log -r "$revision" --no-graph -T 'change_id.shortest(12)')
commit_id=$(jj log -r "$revision" --no-graph -T 'commit_id')
git_dir=$(git rev-parse --git-dir)
report_dir="$git_dir/jj-reviews"
script_dir=$(cd "$(dirname "$0")" && pwd)
schema="$script_dir/review-schema.json"
report="$report_dir/${change_id}-${commit_id:0:12}.json"
mkdir -p "$report_dir"

prompt="Perform an independent code review of Git commit $commit_id only. Do not modify any files. Read AGENTS.md before reviewing. Inspect the changes introduced by the commit and report every actionable correctness bug, regression, concurrency issue, error-handling defect, security issue, and material test gap. Return an empty findings array only when there are no actionable problems. Use an empty file string and line 0 when a finding has no precise source location."

echo "Running Codex review for change $change_id ($commit_id)..." >&2
if ! codex exec \
  --ephemeral \
  --sandbox read-only \
  --output-schema "$schema" \
  --output-last-message "$report" \
  "$prompt"; then
  echo "review gate failed: Codex review did not complete" >&2
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
  echo "Codex review found $finding_count advisory problem(s):" >&2
  jq -r '.findings[] | "[\(.severity | ascii_upcase)] \(.title)\n\(if .file != "" then "  at \(.file):\(.line)\n" else "" end)  \(.description)\n"' "$report" >&2
  echo "Full review: $report" >&2
else
  echo "Codex review passed with zero findings." >&2
fi

jj bookmark set "$bookmark" -r "$revision"
echo "Review report: $report" >&2
