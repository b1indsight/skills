#!/usr/bin/env bash
set -euo pipefail

# Exercise installation conflicts and diagnosis in an isolated source repository.
repository_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
cache_root="$repository_root/.cache/$(date +%F)"
mkdir -p "$cache_root"
temporary_root=$(mktemp -d "$cache_root/skills-tests.XXXXXX")
trap 'rm -rf "$temporary_root"' EXIT
output="$temporary_root/output.log"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  if [[ -f "$output" ]]; then cat "$output" >&2; fi
  exit 1
}

run_ok() {
  if ! "$@" >"$output" 2>&1; then fail "command should succeed: $*"; fi
}

run_fails() {
  if "$@" >"$output" 2>&1; then fail "command should fail: $*"; fi
}

assert_absent() {
  [[ ! -e "$1" && ! -L "$1" ]] || fail "unexpected entry: $1"
}

assert_link() {
  [[ -L "$1" ]] || fail "expected symlink: $1"
  [[ "$(readlink "$1")" == "$2" ]] || fail "unexpected symlink target: $1"
}

copy_cli() {
  mkdir -p "$1/scripts"
  cp "$repository_root/scripts/skills.sh" "$1/scripts/skills.sh"
  cp "$repository_root/scripts/skill-dependencies.txt" "$1/scripts/skill-dependencies.txt"
}

make_skill() {
  mkdir -p "$1/$2"
  printf '%s\n' '---' "name: $2" 'description: Fixture skill.' '---' >"$1/$2/SKILL.md"
}

source_root="$temporary_root/source repo"
copy_cli "$source_root"
for skill in alpha beta plan-first-workflow jj-review-gate; do
  make_skill "$source_root" "$skill"
done
cli="$source_root/scripts/skills.sh"

# Both project and repository aliases must resolve to physical absolute targets.
project="$temporary_root/project with spaces"
mkdir -p "$project"
ln -s "$project" "$temporary_root/project alias"
ln -s "$source_root" "$temporary_root/source alias"
run_ok bash "$temporary_root/source alias/scripts/skills.sh" install "$temporary_root/project alias" alpha beta
assert_link "$project/.agents/skills/alpha" "$source_root/alpha"
assert_link "$project/.agents/skills/beta" "$source_root/beta"
run_ok bash "$cli" install "$project" alpha beta
run_ok bash "$cli" doctor "$project"

# Preserve a relative same-source link, and repair a stale link after a repo move.
relative_project="$temporary_root/relative project"
mkdir -p "$relative_project/.agents/skills"
relative_target='../../../source repo/alpha'
ln -s "$relative_target" "$relative_project/.agents/skills/alpha"
ln -s "$temporary_root/old repo/beta" "$relative_project/.agents/skills/beta"
run_ok bash "$cli" install "$relative_project" alpha beta
assert_link "$relative_project/.agents/skills/alpha" "$relative_target"
assert_link "$relative_project/.agents/skills/beta" "$source_root/beta"

# Preflight every requested skill so a later conflict cannot leave a partial install.
conflict_project="$temporary_root/batch conflict"
mkdir -p "$conflict_project/.agents/skills"
printf '%s\n' 'keep this file' >"$conflict_project/.agents/skills/beta"
run_fails bash "$cli" install "$conflict_project" alpha beta
assert_absent "$conflict_project/.agents/skills/alpha"
[[ "$(cat "$conflict_project/.agents/skills/beta")" == 'keep this file' ]] || fail 'conflicting file changed'
run_fails bash "$cli" doctor "$conflict_project" beta

directory_project="$temporary_root/directory conflict"
mkdir -p "$directory_project/.agents/skills/alpha"
printf '%s\n' 'keep this directory' >"$directory_project/.agents/skills/alpha/sentinel"
run_fails bash "$cli" install "$directory_project" alpha
[[ "$(cat "$directory_project/.agents/skills/alpha/sentinel")" == 'keep this directory' ]] || fail 'conflicting directory changed'

external_source="$temporary_root/external repo"
make_skill "$external_source" alpha
external_project="$temporary_root/external skills"
mkdir -p "$external_project/.agents/skills"
ln -s "$external_source/alpha" "$external_project/.agents/skills/alpha"
run_fails bash "$cli" install "$external_project" alpha
assert_link "$external_project/.agents/skills/alpha" "$external_source/alpha"
run_fails bash "$cli" doctor "$external_project"
run_fails bash "$cli" doctor "$external_project" alpha
make_skill "$external_source" external-only
external_only_project="$temporary_root/external only skills"
mkdir -p "$external_only_project/.agents/skills"
ln -s "$external_source/external-only" "$external_only_project/.agents/skills/external-only"
run_ok bash "$cli" doctor "$external_only_project"
assert_link "$external_only_project/.agents/skills/external-only" "$external_source/external-only"

# Bad names and missing install arguments must not even create the skill container.
invalid_project="$temporary_root/invalid inputs"
mkdir -p "$invalid_project"
run_fails bash "$cli" install "$invalid_project" alpha unknown
assert_absent "$invalid_project/.agents"
run_fails bash "$cli" install "$invalid_project" alpha ../alpha
assert_absent "$invalid_project/.agents"
run_fails bash "$cli" install "$invalid_project"
assert_absent "$invalid_project/.agents"
run_ok bash "$cli" doctor "$invalid_project"
[[ -s "$output" ]] || fail 'empty installation diagnosis should explain its result'
run_fails bash "$cli" doctor "$invalid_project" alpha
assert_absent "$invalid_project/.agents"

# A container symlink could redirect writes outside the project; reject both levels.
redirected="$temporary_root/redirected directory"
mkdir -p "$redirected"
agents_alias_project="$temporary_root/agents alias project"
mkdir -p "$agents_alias_project"
ln -s "$redirected" "$agents_alias_project/.agents"
run_fails bash "$cli" install "$agents_alias_project" alpha
run_fails bash "$cli" doctor "$agents_alias_project"
assert_absent "$redirected/skills"
skills_alias_project="$temporary_root/skills alias project"
mkdir -p "$skills_alias_project/.agents"
ln -s "$redirected" "$skills_alias_project/.agents/skills"
run_fails bash "$cli" install "$skills_alias_project" alpha
run_fails bash "$cli" doctor "$skills_alias_project"
assert_absent "$redirected/alpha"

# Diagnosis reports dangling links from any source and leaves every entry untouched.
broken_project="$temporary_root/broken links"
mkdir -p "$broken_project/.agents/skills"
broken_target="$temporary_root/missing external/unknown"
ln -s "$broken_target" "$broken_project/.agents/skills/unknown"
run_fails bash "$cli" doctor "$broken_project"
assert_link "$broken_project/.agents/skills/unknown" "$broken_target"

# A deleted SKILL.md leaves a live directory link that must still be diagnosed.
incomplete_source="$temporary_root/incomplete source"
copy_cli "$incomplete_source"
mkdir -p "$incomplete_source/alpha"
incomplete_project="$temporary_root/incomplete project"
mkdir -p "$incomplete_project/.agents/skills"
ln -s "$incomplete_source/alpha" "$incomplete_project/.agents/skills/alpha"
run_fails bash "$incomplete_source/scripts/skills.sh" doctor "$incomplete_project"
assert_link "$incomplete_project/.agents/skills/alpha" "$incomplete_source/alpha"

# Dependency paths are relative to the source repo, not the project's installed set.
dependency_source="$temporary_root/dependency source"
copy_cli "$dependency_source"
make_skill "$dependency_source" plan-first-workflow
dependency_cli="$dependency_source/scripts/skills.sh"
dependency_project="$temporary_root/dependency project"
mkdir -p "$dependency_project"
run_fails bash "$dependency_cli" install "$dependency_project" plan-first-workflow
assert_absent "$dependency_project/.agents"
mkdir -p "$dependency_project/.agents/skills"
ln -s "$dependency_source/plan-first-workflow" "$dependency_project/.agents/skills/plan-first-workflow"
run_fails bash "$dependency_cli" doctor "$dependency_project"
assert_link "$dependency_project/.agents/skills/plan-first-workflow" "$dependency_source/plan-first-workflow"
make_skill "$dependency_source" jj-review-gate
run_ok bash "$dependency_cli" install "$dependency_project" plan-first-workflow
run_ok bash "$dependency_cli" doctor "$dependency_project" plan-first-workflow
assert_absent "$dependency_project/.agents/skills/jj-review-gate"

printf '%s\n' 'skills installation and diagnosis tests passed'
