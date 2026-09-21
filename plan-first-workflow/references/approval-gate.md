# Phase 3: Approval gate — STOP

You're here because a draft PR carrying the plan is open and the user hasn't approved it yet.
This is a hard stop, and it exists for one reason: planning first is worthless if you plan and
then immediately build without giving the user the chance to redirect.

- **Do not write tests or implementation code** until the user **explicitly** approves the plan.
- Approval arrives as a review or comment. It is **not** a signal to merge or close the plan PR
  — that PR stays open and becomes the implementation PR (see the core invariant in `SKILL.md`).
- If the user asks for changes, append the updated requirements, proposed plan amendments,
  and design trade-offs to the feature-record timeline. Preserve the initial plan and label
  implementation as pending. Re-push on the **same** bookmark to update the same draft PR,
  then wait for approval. This is still a docs-only push, so it does not go through the code
  review gate (see `references/jj-mechanics.md`).
- Record explicit plan approval in the timeline, identifying the plan and amendments it covers.

## Then

Once — and only once — the user has explicitly approved the plan, go to
`references/implement.md`.
