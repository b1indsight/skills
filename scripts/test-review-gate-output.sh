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
          [[ "$3" == "${FAKE_EXPECTED_REVISION:-@}" ]] || exit 2
          printf '%s\n' "$FAKE_COMMIT_ID"
        else
          printf '%s' "$FAKE_CHANGE_ID"
        fi
        ;;
      diff) printf '%s\n' "$FAKE_STDIN_SENTINEL" ;;
      bookmark) printf '%s\n' "$*" >"$FAKE_BOOKMARK_LOG"; exit 2 ;;
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
      elif [[ "$1" == "--output-schema" ]]; then
        [[ -f "$2" ]] || exit 2
        shift 2
      else
        shift
      fi
    done
    stdin=$(cat)
    printf '%s\n' "$stdin"
    printf '%s\n' "$stdin" >&2
    [[ "${FAKE_CODEX_FAIL:-0}" == "0" ]] || exit 1
    case "${FAKE_REVIEW_KIND:-none}" in
      none) printf '{"summary":"ok","findings":[]}\n' >"$report" ;;
      invalid) printf '{"summary":"invalid","findings":null}\n' >"$report" ;;
      high|critical)
        printf '{"summary":"issue","findings":[{"severity":"%s","title":"Confirmed defect","description":"A reachable regression","file":"src/main.rs","line":1}]}\n' \
          "$FAKE_REVIEW_KIND" >"$report"
        ;;
      *) exit 2 ;;
    esac
    exit
    ;;
esac

repository_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
gates=(
  "$repository_root/jj-review-gate/scripts/review.sh"
  "$repository_root/plan-first-workflow/scripts/review.sh"
)

cache_root="$repository_root/.cache/$(date +%F)"
mkdir -p "$cache_root"
temporary_root=$(mktemp -d "$cache_root/review-gate-output.XXXXXX")
trap 'rm -rf "$temporary_root"' EXIT
fake_bin="$temporary_root/bin"
export FAKE_WORKSPACE="$temporary_root/workspace"
export FAKE_GIT_DIR="$FAKE_WORKSPACE/.git"
export FAKE_COMMIT_ID=0123456789abcdef0123456789abcdef01234567
export FAKE_CHANGE_ID=abcdefghijkl
export FAKE_STDIN_SENTINEL=PRIVATE_STDIN_SENTINEL
export FAKE_BOOKMARK_LOG="$temporary_root/bookmark.log"
mkdir -p "$fake_bin" "$FAKE_GIT_DIR"
mkdir -p "$FAKE_WORKSPACE/.agents/skills"
ln -s "$repository_root/plan-first-workflow" "$FAKE_WORKSPACE/.agents/skills/plan-first-workflow"
gates[1]="$FAKE_WORKSPACE/.agents/skills/plan-first-workflow/scripts/review.sh"

for command in jj git codex; do
  ln -s "$repository_root/scripts/test-review-gate-output.sh" "$fake_bin/$command"
done

stdout_file="$temporary_root/stdout"
stderr_file="$temporary_root/stderr"

for gate in "${gates[@]}"; do
  # Review must never move a bookmark, including on successful gate results.
  for kind in none high critical invalid execution-failure; do
    : >"$FAKE_BOOKMARK_LOG"
    review_revision=@-
    expected_revision=@-
    if [[ "$kind" == "none" ]]; then
      review_revision=
      expected_revision=@
    fi
    codex_fail=0
    review_kind=$kind
    if [[ "$kind" == "execution-failure" ]]; then
      codex_fail=1
      review_kind=none
    fi
    result_status=0
    PATH="$fake_bin:$PATH" FAKE_REVIEW_KIND="$review_kind" FAKE_CODEX_FAIL="$codex_fail" \
      FAKE_EXPECTED_REVISION="$expected_revision" JJ_REVIEW_TIMEOUT_SECONDS=5 \
      "$gate" ${review_revision:+"$review_revision"} >"$stdout_file" 2>"$stderr_file" || result_status=$?
    result_output=$(<"$stderr_file")
    result_stdout=$(<"$stdout_file")
    [[ "$result_output" != *"$FAKE_STDIN_SENTINEL"* ]]
    [[ "$result_stdout" != *"$FAKE_STDIN_SENTINEL"* ]]
    [[ ! -s "$FAKE_BOOKMARK_LOG" ]]
    artifact_prefix="$FAKE_GIT_DIR/jj-reviews/$FAKE_CHANGE_ID-${FAKE_COMMIT_ID:0:12}"
    [[ -f "$artifact_prefix.diff" ]]
    [[ "$(<"$artifact_prefix.diff")" == "$FAKE_STDIN_SENTINEL" ]]

    case "$kind" in
      none|high)
        [[ "$result_status" == "0" ]]
        [[ "$result_stdout" == "$FAKE_COMMIT_ID" ]]
        [[ -f "$artifact_prefix.json" ]]
        [[ ! -e "$artifact_prefix.exec.log" ]]
        if [[ "$kind" == "high" ]]; then
          [[ "$result_output" == *"[HIGH] Confirmed defect"* ]]
        fi
        ;;
      critical)
        [[ "$result_status" == "3" ]]
        [[ -z "$result_stdout" ]]
        [[ "$result_output" == *"[CRITICAL] Confirmed defect"* ]]
        [[ ! -e "$artifact_prefix.exec.log" ]]
        ;;
      invalid)
        [[ "$result_status" == "65" ]]
        [[ -z "$result_stdout" ]]
        [[ -f "$artifact_prefix.exec.log" ]]
        ;;
      execution-failure)
        [[ "$result_status" == "70" ]]
        [[ -z "$result_stdout" ]]
        [[ "$result_output" == *"Codex execution log: $artifact_prefix.exec.log"* ]]
        [[ -f "$artifact_prefix.exec.log" ]]
        ;;
    esac
  done

  # The former bookmark argument is no longer accepted by the review-only API.
  result_status=0
  "$gate" feat/test @ >"$stdout_file" 2>"$stderr_file" || result_status=$?
  [[ "$result_status" == "64" ]]
  [[ ! -s "$stdout_file" ]]
done

printf 'review-only gate decisions, commit output, and isolation passed for %d entry points\n' "${#gates[@]}"
