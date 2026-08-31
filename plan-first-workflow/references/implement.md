# Phase 4: Implementation

You're here because the user has explicitly approved the plan. Now build it — following the
approved plan, on the **same** bookmark and PR.

## Build test-first

Write the tests first, then implement until they pass — the tests pin the intended behavior,
and the plan already fixed the shape, so implementation is filling in what both already
describe. Keep test scope proportional to the change's risk (see the `code-principles` skill if
the repo provides it).

## Push through the review gate

This is where real code lands, so this push goes through this skill's bundled review gate.
Instead of running `jj bookmark set` yourself:

1. Finish the code changes in the working-copy change `@`.
2. Set the bookmark by running the bundled gate — `scripts/review-and-bookmark.sh <bookmark>`.
   It reports every finding and sets the bookmark only when none is `critical`; a critical result
   stops the push. Findings never authorize automatic rework. Read `references/review-gate.md`
   for the full workflow, escalated-permission requirement, and explicit rework authorization.
3. Push the bookmark, which updates the **same** PR.

Push the implementation, updated feature doc, and changelog together, all on the same bookmark.
Do not create a new bookmark or PR here. See `references/jj-mechanics.md` for the exact command
sequence and how the review gate slots in.

## Then

Once the implementation is pushed, go to `references/finish.md`.
