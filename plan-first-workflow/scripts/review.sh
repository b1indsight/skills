#!/usr/bin/env bash
set -euo pipefail

# Resolve the shared review implementation through the workflow's source directory.
skill_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
exec "$skill_root/../jj-review-gate/scripts/review.sh" "$@"
