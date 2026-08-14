---
name: plan-first-workflow
description: The plan-first, one-PR, stacked-change feature workflow — write a plan and get explicit user approval on a draft PR before writing any code, then implement test-first as an ordered stack of cohesive Jujutsu changes and keep affected project documentation synchronized on the same bookmark and PR. Use this whenever a task means building, implementing, or adding a feature or any non-trivial change in a repository that follows this workflow, even when the user just says "implement X" or "start on Y" without mentioning a plan.
---

# Plan-First Feature Workflow

A feature moves through four phases, and a plan is reviewed and approved **before any code is
written**. The point is to keep the user in control of direction while changes are still cheap
— a plan is far easier to redirect than a finished branch.

This file is a router. **Locate your current phase below and read only that phase's file** —
you don't need the others until you get there. The core invariant and the trivial-change
escape hatch here always apply.

## Core invariant (always holds)

**One feature = one bookmark = one PR = one ordered stack of cohesive changes.**

The same named bookmark and the same PR carry a feature its whole life. The plan-only PR is
not a throwaway — it *becomes* the implementation PR — but the plan change is not a container
for all later work. So:

- Never open a second PR for the implementation of a feature already planned in a PR.
- Never merge or close the plan-only PR to "start fresh" for code.
- Never skip the plan-approval gate and go straight to implementation.
- Preserve the approved plan as the first change. Start implementation in a new child change.
- Use a separate change only for an independently explainable, reviewable, and revertible intent.
  Follow natural functional boundaries instead of turning every plan step or file group into a
  change, and never target a change count.
- Keep tests and the documentation made true by a behavior in the same change as that behavior.
  Do not create deliberately broken intermediate changes merely to separate file types.
- Before an implementation or fix change's first push, refine it until it is coherent. After it is
  pushed, classify later work by review context, not by channel: feedback from the user or another
  reviewer that evaluates the submitted PR must become one or more child `fix` changes, whether it
  arrives through GitHub or the conversation. A self-discovered, CI, test, or other non-review
  correction may edit its owning change when it remains within that change's original intent. Give
  any genuinely new, independent intent its own child change. Pre-approval plan review remains the
  Phase 3 exception.
- Do not squash or fold the stack into one oversized change before submission. Point the one
  bookmark at the stack tip so the one PR exposes the ordered changes.

Keeping plan, review discussion, and code in one thread means anyone can read a feature's
whole story in one place. Keeping the implementation as a change stack makes each meaningful
functional unit independently understandable without fragmenting that story across PRs.

## Starting-point invariant (always holds)

Start a **new** task from the latest fetched remote state of the project's declared base branch,
not from whatever unrelated change happens to be `@`. Determine the base branch from the
repository's instructions or configuration — do not hard-code `main` — fetch `origin`, and create
the plan change directly on `<base>@origin`. Preserve any unrelated working-copy change; do not
squash, abandon, or rebase it into the new task.

This rule applies only when no plan PR exists for the task. When resuming an existing plan,
bookmark, or PR, continue from that task's current change stack instead of restarting from the base
branch.

## Documentation invariant (always holds)

Treat affected project documentation as part of the implementation, not as optional cleanup.
Assess documentation impact during planning, synchronize current-truth documentation with the
actual implementation, and validate it before marking the PR ready. If no project documentation
needs to change, record why in the final handoff. This invariant covers project documentation,
not source-code comments or API docstrings.

## Find your current phase

Place yourself by the state of this feature's work, then read the one file that matches:

The four phases subdivide into the numbered steps the phase files and cross-references use.

| You are here when… | Phase (steps) | Read |
| --- | --- | --- |
| A feature or non-trivial change is requested and there's no plan PR for it yet | **Planning** (1–2) | `references/plan.md` |
| A draft PR carrying the plan is open and the user hasn't approved it yet | **Approval gate** (3) | `references/approval-gate.md` |
| The user has explicitly approved the plan and you're building it | **Implementation** (4) | `references/implement.md` |
| The code is pushed on the PR and you're validating, marking ready, or merging | **Finishing** (5–6) | `references/finish.md` |

The command mechanics several phases share — the `jj` flow and this skill's bundled code review
gate — live in `references/jj-mechanics.md` and `references/review-gate.md`. Read them when a
phase file sends you there. Shared documentation-impact and synchronization rules live in
`references/documentation.md`; read it when a phase file sends you there.

## Small changes: skip the planning, not the code review

There are two separate reviews here — the human **plan approval** (Phase 3) and the automated
**code review gate** (`references/review-gate.md`) — and small changes treat them differently.

Trivial and very small changes skip the *planning ceremony*: no plan doc, no draft PR, no
plan-approval gate. A one-line fix has no design to approve. Create a cohesive change and open a
normal (non-draft) PR; do not force artificial splitting when the work has only one logical unit.

They do **not** automatically skip the code review gate, because that gate keys off whether a
push carries code, not whether the change was planned:

- A small **code** change (a one-line fix, a small tweak) is still a code-bearing push, so set
  its bookmark through the bundled review gate — it's cheap and advisory, and a one-liner can
  still be wrong.
- A **non-code** change (a typo, a comment, a doc tweak) has no code to review, so it skips the
  gate too, like any docs-only push.

Reserve this for changes that are genuinely small; if something starts small but turns into real
feature work, fold it back into the full workflow.

Even when a change skips planning, perform the compact documentation-impact and finishing checks
in `references/documentation.md`. A docs-only change still skips the code review gate; a small code
change still updates any project documentation its behavior or contracts affect.
