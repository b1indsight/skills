#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  skills.sh install <project-root> <skill>...
  skills.sh doctor <project-root> [<skill>...]

Install absolute symlinks in <project-root>/.agents/skills. Repeated installs
preserve correct links and repair broken links. Conflicting entries are kept.
Doctor checks links and declared source dependencies without changing files.
Without skill names, doctor checks existing installations only.
USAGE
}

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi
case "$1" in
  -h|--help) usage; exit 0 ;;
  install|doctor) action=$1 ;;
  *) usage >&2; exit 2 ;;
esac
shift
if [[ $# -eq 0 ]]; then
  usage >&2
  exit 2
fi
project=$1
shift
if [[ "$action" == install && $# -eq 0 ]]; then
  usage >&2
  exit 2
fi

repo_root=$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
if [[ ! -d "$project" ]]; then
  printf 'ERROR: project directory does not exist: %s\n' "$project" >&2
  exit 1
fi
project_root=$(cd -- "$project" && pwd -P)
skills_dir="$project_root/.agents/skills"
dependencies="$repo_root/scripts/skill-dependencies.txt"
failures=0

error() {
  printf 'ERROR: %s\n' "$*" >&2
  failures=$((failures + 1))
}

valid_name() {
  [[ "$1" =~ ^[a-z0-9][a-z0-9_-]*$ ]]
}

# Container symlinks can redirect writes outside the project. Individual skill
# symlinks are expected, but their parent directories must be real directories.
for container in "$project_root/.agents" "$skills_dir"; do
  if [[ -L "$container" ]]; then
    error "installation container is a symlink: $container"
  elif [[ -e "$container" && ! -d "$container" ]]; then
    error "installation container is not a directory: $container"
  fi
done
if [[ "$failures" -ne 0 ]]; then
  exit 1
fi
if [[ ! -r "$dependencies" ]]; then
  error "source dependency list is not readable: $dependencies"
  exit 1
fi

# Dependencies refer to sibling source definitions, not extra project links.
# For example, plan-first-workflow resolves jj-review-gate from its real source.
check_source() {
  local skill=$1 before=$failures owner dependency extra
  if ! valid_name "$skill"; then
    error "invalid skill name: $skill"
    return 1
  fi
  if [[ ! -f "$repo_root/$skill/SKILL.md" || ! -r "$repo_root/$skill/SKILL.md" ]]; then
    error "unknown or unreadable source skill: $skill"
    return 1
  fi
  while read -r owner dependency extra; do
    [[ -n "$owner" && "$owner" != \#* ]] || continue
    [[ "$owner" == "$skill" ]] || continue
    if [[ -n "$extra" ]] || ! valid_name "$dependency"; then
      error "invalid source dependency entry for $skill"
    elif [[ ! -f "$repo_root/$dependency/SKILL.md" || ! -r "$repo_root/$dependency/SKILL.md" ]]; then
      error "$skill requires source skill $dependency alongside it in $repo_root"
    fi
  done < "$dependencies"
  [[ "$failures" -eq "$before" ]]
}

same_source() {
  local target=$1 source_dir=$2 actual expected
  [[ -d "$target" && -d "$source_dir" ]] || return 1
  actual=$(cd -- "$target" && pwd -P) || return 1
  expected=$(cd -- "$source_dir" && pwd -P) || return 1
  [[ "$actual" == "$expected" ]]
}

# Compare physical directories so an existing relative link to the same source
# is preserved. Conflicting files and valid links never become install targets.
check_target() {
  local skill=$1 target="$skills_dir/$1"
  if [[ ! -e "$target" && ! -L "$target" ]]; then
    if [[ "$action" == doctor ]]; then
      error "skill is not installed: $skill ($target)"
    fi
  elif [[ ! -L "$target" ]]; then
    error "refusing real file or directory: $target"
  elif [[ ! -e "$target" ]]; then
    if [[ "$action" == doctor ]]; then
      error "broken skill link: $target"
    fi
  elif [[ ! -d "$target" ]]; then
    error "skill link does not point to a directory: $target"
  elif ! same_source "$target" "$repo_root/$skill"; then
    error "skill link does not resolve to $repo_root/$skill: $target"
  elif [[ "$action" == doctor ]]; then
    printf 'OK: %s\n' "$skill"
  fi
}

if [[ "$action" == doctor && $# -eq 0 ]]; then
  shopt -s dotglob
  for target in "$skills_dir"/*; do
    [[ -e "$target" || -L "$target" ]] || continue
    skill=${target##*/}
    if [[ -f "$repo_root/$skill/SKILL.md" ]] ||
       { [[ -L "$target" ]] && same_source "$target" "$repo_root/$skill"; }; then
      set -- "$@" "$skill"
    elif [[ -L "$target" && ! -e "$target" ]]; then
      error "broken skill link: $target"
    else
      printf 'SKIP: external entry %s\n' "$skill"
    fi
  done
fi

# Preflight the entire request before creating any directory or link. A conflict
# in a later skill must not leave the earlier skills partially installed.
for skill in "$@"; do
  if check_source "$skill"; then
    check_target "$skill"
  fi
done
if [[ "$failures" -ne 0 ]]; then
  exit 1
fi

if [[ "$action" == doctor ]]; then
  printf 'Doctor passed: %d repository skill(s) checked.\n' "$#"
  exit 0
fi

mkdir -p "$skills_dir"
for skill in "$@"; do
  target="$skills_dir/$skill"
  source_dir="$repo_root/$skill"
  if [[ -L "$target" && -e "$target" ]]; then
    printf 'UNCHANGED: %s\n' "$target"
  elif [[ -L "$target" ]]; then
    # Only a broken link reaches this branch; never unlink a real entry.
    unlink "$target"
    ln -s "$source_dir" "$target"
    printf 'REPAIRED: %s -> %s\n' "$target" "$source_dir"
  else
    ln -s "$source_dir" "$target"
    printf 'INSTALLED: %s -> %s\n' "$target" "$source_dir"
  fi
done
