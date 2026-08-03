# Phase 4: Implementation

You're here because the user has explicitly approved the plan. Now build it — following the
approved plan, on the **same** bookmark and PR.

## Build test-first

Write the tests first, then implement until they pass — the tests pin the intended behavior,
and the plan already fixed the shape, so implementation is filling in what both already
describe. Keep test scope proportional to the change's risk (see the `code-principles` skill if
the repo provides it).

## Keep project documentation synchronized

Read `references/documentation.md`, then re-evaluate the approved documentation-impact section
against the actual implementation. Update the affected current-truth docs, examples, changelog,
and indexes in the same working change as the behavior they describe. Document actual behavior,
not merely the approved intention; if implementation materially deviates from the plan, preserve
the original decision record and add the resulting status or deviation instead of rewriting its
history. Do not mark a plan implemented before the behavior and validation are complete.

If the final implementation has no project-documentation impact, retain the concrete rationale
for the final handoff. Do not add ceremonial docs solely to satisfy a checklist.

## Push through the review gate

This is where real code lands, so this push goes through this skill's bundled review gate.
Instead of running `jj bookmark set` yourself:

1. Finish the code changes in the working-copy change `@`.
2. Set the bookmark by running the bundled gate — `scripts/review-and-bookmark.sh <bookmark>`.
   It runs an advisory Codex review over the diff and then sets the bookmark. Report any findings
   it returns; they're advisory and don't block the push. Read `references/review-gate.md` for the
   full workflow, the escalated-permission requirement, and the rework cap.
3. Push the bookmark, which updates the **same** PR.

Push the implementation and every required project-documentation update together, all on the same
bookmark. Do not create a new bookmark or PR here. See `references/jj-mechanics.md` for the exact
command sequence and how the review gate slots in.

## Then

Once the implementation is pushed, go to `references/finish.md`.
