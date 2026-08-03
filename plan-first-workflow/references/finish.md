# Phase 5–6: Finishing

You're here because the code is pushed on the PR. What's left is to prove it's ready, promise
that to the reviewer, and merge.

## 5. Validate & mark ready

Run the project's own checks (tests, typecheck / lint, build — whatever `AGENTS.md` defines) and
re-read the final diff. Mark the draft PR ready **only** when implementation, docs, changelog,
and validation are all complete. Marking a PR "ready" is a promise to the reviewer that it is
actually reviewable — don't make that promise early.

Run the completion checks in `references/documentation.md` before making that promise:

- Compare the final diff with the plan's documentation-impact section and account for scope drift.
- Confirm current-truth docs, tracked examples, changelog, and indexes match the implementation.
- Search for stale identifiers and validate affected links, commands, schemas, and snippets.
- Run the repository's prescribed documentation generators or checks.
- Update the plan's status and actual deviations only after the implementation is validated.

In the final handoff, list the project documents updated and documentation checks run. If none
changed, state the concrete impact rationale.

If validation forces more code changes, that's another code-bearing push: route it through the
bundled review gate again, on the same bookmark (see `references/review-gate.md`).

## 6. Merge

Merge only after final review of the **completed implementation**, never at the plan stage.
After merge, re-sync (`jj git fetch --remote origin`) and rebase any remaining work onto the new
base before continuing.
