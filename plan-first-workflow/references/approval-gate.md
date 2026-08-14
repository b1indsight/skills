# Phase 3: Approval gate — STOP

You're here because a draft PR carrying the plan is open and the user hasn't approved it yet.
This is a hard stop, and it exists for one reason: planning first is worthless if you plan and
then immediately build without giving the user the chance to redirect.

- **Do not write tests or implementation code** until the user **explicitly** approves the plan.
- Approval arrives as a review or comment. It is **not** a signal to merge or close the plan PR
  — that PR stays open and becomes the implementation PR (see the core invariant in `SKILL.md`).
- If the user asks for changes, revise the plan on the **same** bookmark and re-push, which
  updates the same draft PR, then wait again. Keep these pre-approval revisions in the plan change;
  do not start the implementation stack yet. This is still a docs-only push, so it does not go
  through the code review gate (see `references/jj-mechanics.md`).

If review changes user-visible behavior, contracts, configuration, architecture, or document
placement, revise the plan's documentation-impact section too. Keep current-truth documentation
unchanged until the approved behavior is actually implemented; see `references/documentation.md`.

## Then

Once — and only once — the user has explicitly approved the plan, go to
`references/implement.md`. Before writing product or test code, create a new child change so the
approved plan remains an isolated first change in the PR.
