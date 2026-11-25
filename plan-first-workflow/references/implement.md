# Phase 3: Implementation

Implement the explicitly approved plan and its approved amendments on the same bookmark and PR.

## Implement the approved behavior

Start implementation with `jj new "$bookmark"` on the published feature tip. The working copy moves to the new child; the bookmark stays on its parent. Move the bookmark onto implementation code only after review, using the exact reviewed commit ID.

Keep only these two kinds of new or changed tests:

- **Behavior tests:** Derive cases only from the approved acceptance demo and its expected outcomes. When an existing module's behavior changes, update its corresponding behavior test in place rather than adding a parallel test. Do not omit or weaken an approved expectation; record the reason for any proposed change in the timeline and obtain explicit approval first.
- **Regression tests:** For a bug fix, reproduce the reported failure at the affected interface, confirm the test fails for that reason before the fix, and run it unchanged against the fix. If the demo-derived behavior test already reproduces the bug, use that same case rather than duplicating it.

Implement the interface changes with their affected callers, or update the existing algorithm. Keep caller-visible guarantees beside the declarations and comment on non-obvious implementation choices where they are made. Run the behavior and applicable regression tests against the real implementation, along with the project's existing required checks. Temporary validation probes and ablation experiments are not additional committed tests.

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

Prepare the implementation, feature-record update, and changelog as one described commit on the published feature tip. Follow the [code-bearing push sequence](jj-mechanics.md) to review that exact commit and publish it on the same bookmark and PR. A critical finding or execution failure stops publication; follow the [review and rework rules](review-gate.md).

## Then

Once the implementation is pushed, go to [finish.md](finish.md).
