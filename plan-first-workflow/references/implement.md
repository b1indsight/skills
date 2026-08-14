# Phase 4: Implementation

You're here because the user has explicitly approved the plan. Now build it — following the
approved plan, on the **same** bookmark and PR, as an ordered stack of cohesive child changes.

## Build the change stack

Before touching product or test code, make sure the working copy is a new empty child of the
approved plan. If `@` is still the plan change, start the first implementation unit with
`jj new -m "type(scope): concise functional outcome"`. If an empty child already exists, describe
and use it instead of creating another. Never add implementation code to the plan change.

Use the approved implementation order to choose the stack, then build it one unit at a time:

1. Give one change one independently explainable, reviewable, and revertible functional intent.
   Combine enabling work, migrations, and behavior that only make sense as one complete outcome;
   split only where another unit has standalone review or rollback value.
2. Put the unit's tests, implementation, and directly affected documentation together. A finished
   change should be understandable on its own and pass its relevant checks; combine inseparable
   steps instead of preserving a knowingly broken intermediate change.
3. Run the unit's proportional checks and inspect its diff before moving on. Keep its description
   accurate and non-empty.
4. Start the next unit with `jj new -m "type(scope): concise functional outcome"` only when another
   independently meaningful intent remains. Do not create a trailing empty change after the final
   unit.

Do not target a minimum or maximum number of changes. A small feature may need one implementation
change; a larger feature may expose several natural boundaries.

## Build test-first

Within each functional change, write the tests first, then implement until they pass — the tests
pin the intended behavior, and the plan already fixed the shape, so implementation is filling in
what both already describe. Do not preserve the temporary red test state as its own finished
change. Keep test scope proportional to the change's risk (see the `code-principles` skill if the
repo provides it).

## Keep project documentation synchronized

Read `references/documentation.md`, then re-evaluate the approved documentation-impact section
against the actual implementation. Update the affected current-truth docs, examples, changelog,
and indexes in the same cohesive change as the behavior they describe. If documentation describes
the cumulative result of several changes, put it in the final change that makes the whole claim
true. Document actual behavior, not merely the approved intention; if implementation materially
deviates from the plan, preserve the original decision record and add the resulting status or
deviation instead of rewriting its history. Do not mark a plan implemented before the behavior
and validation are complete.

If the final implementation has no project-documentation impact, retain the concrete rationale
for the final handoff. Do not add ceremonial docs solely to satisfy a checklist.

## Refine changes; isolate reviewer follow-ups

Before an implementation or fix change's first push, freely edit, split, squash, or reorder the
unsubmitted work to make each change coherent. Correct an unsubmitted change in place when the
correction belongs to that intent instead of accumulating temporary fixup children. If an earlier
change is rewritten, revalidate its affected descendants.

An implementation or fix change becomes **submitted** once it has been pushed and appears in the
PR. Classify later work by context and intent, not by the account or channel it came from. A
request is **review feedback** when the user or another reviewer evaluates the submitted PR and
asks for a modification; GitHub reviews, PR comments, and the current conversation all count.

- For review feedback, never `jj edit`, squash, or absorb the modification into a submitted
  change. Create child changes with `fix(<scope>): ...` descriptions instead. Combine tightly
  coupled review requests for one functional concern, and split only those with
  independent review or rollback value; do not create one fix change per comment.
- For a self-discovered correction, CI or test failure, validation finding, or user request that is
  not reviewing the submitted PR, edit the owning submitted change directly when the work stays
  within its original intent. Revalidate every affected descendant and send the resulting
  code-bearing submission batch through the review gate again before pushing.
- For a genuinely new, independently explainable and revertible intent, create a child change
  regardless of who requested it.

Pre-approval feedback on the plan change continues to follow the Phase 3 loop instead.

## Submit the stack through one review gate

This is where real code lands. Review the complete code-bearing submission batch **once**, not once
per change, and do not run `jj bookmark set` yourself:

1. Finish and validate the local stack, then choose its exact tip as the target revision.
2. Run `scripts/review-and-bookmark.sh <bookmark> [target]` once. The target defaults to `@`.
3. Let the gate resolve the task's previous submitted state from `<bookmark>@origin` and review one
   net diff from that state to the target. For a first-ever bookmark with no remote state, it uses
   an existing local bookmark that still points to the prior task state, or otherwise the target's
   single parent.
4. Report every returned suggestion to the user. Suggestions are advisory: they do not block the
   bookmark or force rework. Only review execution or result-parsing failure blocks submission.
5. After a valid review result, let the script set the bookmark to the exact reviewed target, then
   push once to update the **same** PR.

The review range is the code modification being uploaded in this bookmark update, regardless of
how many cohesive changes the batch contains. Do not create a new bookmark or PR, and do not squash
the coherent stack into one oversized change before pushing it. See `references/jj-mechanics.md`
for the exact command sequence and `references/review-gate.md` for range resolution, permissions,
failure handling, and the rework cap.

## Then

Once the implementation is pushed, go to `references/finish.md`.
