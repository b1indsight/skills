# Phase 3: Implementation

You're here because the user has explicitly approved the plan. Now build it — following the
approved plan and its approved amendments, on the **same** bookmark and PR.

## Implement the approved behavior

Start a child change after the draft commit. Fill the declared methods or update the existing algorithm. Keep caller-visible guarantees beside the declarations and comment on non-obvious implementation choices where they are made. Run the first-commit acceptance test against the real implementation; add other tests only for risks it does not cover. Run the project's required checks.

Treat the first-commit assertions as the acceptance baseline. Do not remove, skip, or weaken them to make the test pass. If a requirement changes, record which assertion would change and why in the feature-record timeline, and obtain explicit user approval before changing it.

Keep the module map and end-to-end walkthrough current under the [document rules](feature-record.md). If the approved architecture, boundary behavior, or choice of approach must change, append the amendment to the timeline and obtain approval before implementing the revised scope.

## Validate added complexity with ablation experiments

After implementation and before automated code review, test whether added complexity is
necessary and effective. Compare the implementation with simpler variants that remove or
replace each material mechanism, using the same representative inputs and conditions.
Change one mechanism at a time; compare coupled mechanisms together when needed.

Use the plan's acceptance criteria to judge observed behavior, benefits, and costs. Keep a
mechanism only when evidence shows that a simpler variant misses a requirement or makes a
meaningful trade-off that justifies the complexity; otherwise simplify the implementation.
Report the setup, reproducible commands, results, and limitations in the PR evidence. If the comparison changes a design decision, append the decision and its rationale to the timeline.
A proposed experiment or plausible explanation is not evidence; if a comparison cannot run
or is inconclusive, record the limitation. Resolve the uncertainty or defer the unsupported
mechanism before review.

Keep experiments proportional to the change. If no material complexity was introduced, note
why ablation does not apply. After simplifying, rerun affected checks before review.

## Push through the review gate

This is where real code lands, so this push goes through the standalone `jj-review-gate` skill.
Keep review and publication as separate actions:

1. Finish the code changes in the working-copy change `@`.
2. Run `scripts/review.sh [revision]`. It reports every finding and returns the reviewed commit
   ID only when the gate passes. A critical result or execution failure stops publication.
   Read [review-gate.md](review-gate.md) for the execution and rework authorization rules.
3. After a pass, set the existing bookmark to the returned commit ID with
   `jj bookmark set <bookmark> -r <reviewed-commit-id> --ignore-working-copy`.
4. Push the bookmark to update the **same** PR.

Push the implementation, updated feature-record document, and changelog together, all on the
same bookmark. Do not create a new bookmark or PR here.
See [jj-mechanics.md](jj-mechanics.md) for the exact command sequence and how the review gate slots in.

## Then

Once the implementation is pushed, go to [finish.md](finish.md).
