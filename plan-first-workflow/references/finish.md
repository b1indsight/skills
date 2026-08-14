# Phase 5–6: Finishing

You're here because the code is pushed on the PR. What's left is to prove it's ready, promise
that to the reviewer, and merge.

## 5. Validate & mark ready

Run the project's own checks (tests, typecheck / lint, build — whatever `AGENTS.md` defines) and
re-read the complete change stack and final diff. Confirm that every change has a precise
description and a coherent responsibility, that no empty or knowingly broken intermediate change
remains, and that the bookmark points to the intended tip. Mark the draft PR ready **only** when
implementation, docs, changelog, and validation are all complete. Do not squash the stack before
submission or readiness. Marking a PR "ready" is a promise to the reviewer that it is actually
reviewable — don't make that promise early.

Run the completion checks in `references/documentation.md` before making that promise:

- Compare the final diff with the plan's documentation-impact section and account for scope drift.
- Confirm current-truth docs, tracked examples, changelog, and indexes match the implementation.
- Search for stale identifiers and validate affected links, commands, schemas, and snippets.
- Run the repository's prescribed documentation generators or checks.
- Update the plan's status and actual deviations only after the implementation is validated.

In the final handoff, list the project documents updated and documentation checks run. If none
changed, state the concrete impact rationale.

Because the implementation is already submitted at this phase, classify follow-up work by review
context and intent, not by channel:

- For a self-discovered validation problem, CI or test failure, or other non-review correction
  within an existing change's original intent, edit that owning change directly. Revalidate its
  affected descendants and route the resulting code-bearing submission batch through the bundled
  review gate once before pushing.
- For feedback in which the user or another reviewer evaluates the submitted PR, add child `fix`
  changes instead of editing submitted changes. GitHub reviews, PR comments, and requests in the
  current conversation all count. Combine tightly coupled requests for one functional concern,
  and split only requests with independent review or rollback value.
- For genuinely new independent functionality, add a child change regardless of who requested it.

Use the unified review gate to advance the same bookmark to the resulting stack tip, report its
suggestions to the user, and push the batch (see `references/review-gate.md`).

## 6. Merge

Merge only after final review of the **completed implementation**, never at the plan stage.
After merge, re-sync (`jj git fetch --remote origin`) and rebase any remaining work onto the new
base before continuing.
