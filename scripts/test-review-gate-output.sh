#!/usr/bin/env bash
set -euo pipefail

# The test script doubles as each fake executable through symlinks in PATH.
case "${0##*/}" in
  jj)
    case "$1" in
      root) printf '%s\n' "$FAKE_WORKSPACE" ;;
      status) ;;
      log)
        if [[ "$*" == *commit_id* ]]; then
          printf '%s\n' "$FAKE_COMMIT_ID"
        else
          printf '%s' "$FAKE_CHANGE_ID"
        fi
        ;;
      diff) printf '%s\n' "$FAKE_STDIN_SENTINEL" ;;
      bookmark) printf '%s\n' "$*" >"$FAKE_BOOKMARK_LOG" ;;
      *) printf 'unexpected fake jj command: %s\n' "$*" >&2; exit 2 ;;
    esac
    exit
    ;;
  git)
    if [[ "$1" == "rev-parse" && "$2" == "--git-dir" ]]; then
      printf '%s\n' "$FAKE_GIT_DIR"
      exit
    fi
    printf 'unexpected fake git command: %s\n' "$*" >&2
    exit 2
    ;;
  codex)
    report=
    while (( $# > 0 )); do
      if [[ "$1" == "--output-last-message" ]]; then
        report=$2
        shift 2
      else
        shift
      fi
    done
    stdin=$(cat)
    printf '%s\n' "$stdin"
    printf '%s\n' "$stdin" >&2
    [[ "${FAKE_CODEX_FAIL:-0}" == "0" ]] || exit 1
    printf '{"summary":"ok","findings":[]}\n' >"$report"
    exit
    ;;
esac

repository_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
gates=(
  "$repository_root/jj-bookmark-review/scripts/review-and-bookmark.sh"
  "$repository_root/plan-first-workflow/scripts/review-and-bookmark.sh"
)

temporary_root=$(mktemp -d)
trap 'rm -rf "$temporary_root"' EXIT
fake_bin="$temporary_root/bin"
export FAKE_WORKSPACE="$temporary_root/workspace"
export FAKE_GIT_DIR="$FAKE_WORKSPACE/.git"
export FAKE_COMMIT_ID=0123456789abcdef0123456789abcdef01234567
export FAKE_CHANGE_ID=abcdefghijkl
export FAKE_STDIN_SENTINEL=PRIVATE_STDIN_SENTINEL
export FAKE_BOOKMARK_LOG="$temporary_root/bookmark.log"
mkdir -p "$fake_bin" "$FAKE_GIT_DIR"

for command in jj git codex; do
  ln -s "$repository_root/scripts/test-review-gate-output.sh" "$fake_bin/$command"
done

for gate in "${gates[@]}"; do
  output=$(PATH="$fake_bin:$PATH" JJ_REVIEW_TIMEOUT_SECONDS=5 "$gate" feat/test @ 2>&1)

  # Real Codex transcripts include the reviewed stdin diff, which must not
  # become part of the parent agent's tool output.
  [[ "$output" != *"$FAKE_STDIN_SENTINEL"* ]]
  artifact_prefix="$FAKE_GIT_DIR/jj-reviews/$FAKE_CHANGE_ID-${FAKE_COMMIT_ID:0:12}"
  [[ -f "$artifact_prefix.json" ]]
  [[ -f "$artifact_prefix.diff" ]]
  [[ ! -e "$artifact_prefix.exec.log" ]]
  [[ "$(<"$artifact_prefix.diff")" == "$FAKE_STDIN_SENTINEL" ]]
  [[ "$(<"$FAKE_BOOKMARK_LOG")" == "bookmark set feat/test -r $FAKE_COMMIT_ID" ]]

  set +e
  failure_output=$(
    PATH="$fake_bin:$PATH" FAKE_CODEX_FAIL=1 JJ_REVIEW_TIMEOUT_SECONDS=5 \
      "$gate" feat/test @ 2>&1
  )
  failure_status=$?
  set -e

  [[ "$failure_status" == "70" ]]
  [[ "$failure_output" != *"$FAKE_STDIN_SENTINEL"* ]]
  [[ "$failure_output" == *"Codex execution log: $artifact_prefix.exec.log"* ]]
  [[ -f "$artifact_prefix.exec.log" ]]
done

printf 'review gate output isolation passed for %d implementations\n' "${#gates[@]}"
