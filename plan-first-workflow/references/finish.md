# Phases 4-5: Finishing

You're here because the code is pushed on the PR. What's left is to prove it's ready, promise
that to the reviewer, and merge.

## 4. Validate & mark ready

Read [the document rules](feature-record.md) before updating the feature record.

Compare the behavior tests with the approved acceptance demo. Verify every expected outcome is exercised unless an explicitly approved amendment accounts for the difference. For a bug fix, verify the regression case passes against the fix.

Run the project's required checks (tests, typecheck, lint, or build as specified in `AGENTS.md`) and re-read the final diff. Follow the affected feature walkthrough from its trigger to its observable result. Verify the module map and flow match what ships. Report validation, ablation outcomes, and remaining limitations in the PR; check that design amendments are in the timeline.
Push the updated document on the same bookmark before marking the PR ready. Mark the draft PR
ready **only** when implementation, docs, changelog, and validation are all complete.

If validation forces more code changes, update the timeline for design amendments and rerun affected ablation comparisons. That's another code-bearing push: route it through the
shared review gate again, on the same bookmark (see [review-gate.md](review-gate.md)).

## 5. Merge

Merge only after final review of the **completed implementation**, never at the plan stage.
After merge, re-sync (`jj git fetch --remote origin`) and rebase any remaining work onto the new
base before continuing.
