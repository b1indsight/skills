#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || ! -L $1 || ! -r $1/SKILL.md ]]; then
  echo 'Usage: check-worker-skill.sh <workspace>/.agents/skills/<linked-skill>' >&2
  exit 2
fi

# Read the linked checkout, even when the task workspace is itself a skills clone.
source_dir=$(cd -P -- "$1" && pwd -P)
snapshot=$(git -C "$source_dir" rev-parse --verify 'HEAD^{commit}')
repo=$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
remote=$(git -C "$repo" ls-remote --exit-code origin HEAD)
tip=${remote%%$'\t'*}
printf 'source: %s\nsnapshot HEAD: %s\nremote HEAD:   %s\n' "$source_dir" "$snapshot" "$tip"
[[ $snapshot == "$tip" ]]
