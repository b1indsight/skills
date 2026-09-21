# Phase 4: Implementation

You're here because the user has explicitly approved the plan. Now build it — following the
approved plan and its approved amendments, on the **same** bookmark and PR.

## Build test-first

Write the tests first, then implement until they pass — the tests pin the intended behavior,
and the plan already fixed the shape, so implementation is filling in what both already
describe. Keep test scope proportional to the change's risk (see the `code-principles` skill if
the repo provides it).

## Maintain the feature-record timeline

As each substantive change is made, append its requirement or trigger, actual implementation,
and design trade-offs to the same feature-record document. Include affected modules and relevant
validation evidence; distinguish completed work from requests or remaining work. Follow the
entry outline in [the template](../assets/feature-record-template.md) and the document rules in
`SKILL.md`. For a material decision, record its context, options, decision/status, and
consequences; link any earlier decision it supersedes. An accepted decision does not mean its
implementation or validation is complete. Updating the timeline does not authorize changes
outside the approved scope.

## Validate added complexity with ablation experiments

After implementation and before automated code review, test whether added complexity is
necessary and effective. Compare the implementation with simpler variants that remove or
replace each material mechanism, using the same representative inputs and conditions.
Change one mechanism at a time; compare coupled mechanisms together when needed.

Use the plan's acceptance criteria to judge observed behavior, benefits, and costs. Keep a
mechanism only when evidence shows that a simpler variant misses a requirement or makes a
meaningful trade-off that justifies the complexity; otherwise simplify the implementation.
Record the setup, reproducible commands, results, and resulting decisions as a feature-record
timeline entry; link larger evidence artifacts instead of copying raw logs into the document.
A proposed experiment or plausible explanation is not evidence; if a comparison cannot run
or is inconclusive, record the limitation. Resolve the uncertainty or defer the unsupported
mechanism before review.

Keep experiments proportional to the change. If no material complexity was introduced, note
why ablation does not apply. After simplifying, rerun affected checks before review.

## Push through the review gate

This is where real code lands, so this push goes through this skill's bundled review gate.
Instead of running `jj bookmark set` yourself:

1. Finish the code changes in the working-copy change `@`.
2. Set the bookmark by running the bundled gate — `scripts/review-and-bookmark.sh <bookmark>`.
   It reports every finding and sets the bookmark only when none is `critical`; a critical result
   stops the push. Findings never authorize automatic rework. Read `references/review-gate.md`
   for the full workflow, escalated-permission requirement, and explicit rework authorization.
3. Push the bookmark, which updates the **same** PR.

Push the implementation, updated feature-record document, and changelog together, all on the
same bookmark. Do not create a new bookmark or PR here.
See `references/jj-mechanics.md` for the exact command sequence and how the review gate slots in.

## Then

Once the implementation is pushed, go to `references/finish.md`.
