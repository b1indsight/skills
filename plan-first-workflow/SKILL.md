---
name: plan-first-workflow
description: The plan-first, one-PR feature workflow — write a plan and get explicit user approval on a draft PR before writing any code, then implement test-first on the same bookmark and PR. Use this whenever a task means building, implementing, or adding a feature or any non-trivial change in a repository that follows this workflow, even when the user just says "implement X" or "start on Y" without mentioning a plan.
---

# Plan-First Feature Workflow

A feature moves through four phases, and a plan is reviewed and approved **before any code is
written**. The point is to keep the user in control of direction while changes are still cheap
— a plan is far easier to redirect than a finished branch.

This file is a router. **Locate your current phase below and read only that phase's file** —
you don't need the others until you get there. The core invariant and the trivial-change
escape hatch here always apply.

## Core invariant (always holds)

**One feature = one bookmark = one PR, from plan through merge.**

The same named bookmark and the same PR carry a feature its whole life. The plan-only PR is
not a throwaway — it *becomes* the implementation PR. So:

- Never open a second PR for the implementation of a feature already planned in a PR.
- Never merge or close the plan-only PR to "start fresh" for code.
- Never skip the plan-approval gate and go straight to implementation.

Keeping plan, review discussion, and code in one thread means anyone can read a feature's
whole story in one place, and the user gets to approve the shape before effort is sunk.

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
phase file sends you there.

## Small changes: skip the planning, not the code review

There are two separate reviews here — the human **plan approval** (Phase 3) and the automated
**code review gate** (`references/review-gate.md`) — and small changes treat them differently.

Trivial and very small changes skip the *planning ceremony*: no plan doc, no draft PR, no
plan-approval gate. A one-line fix has no design to approve. Commit directly and open a normal
(non-draft) PR.

They do **not** automatically skip the code review gate, because that gate keys off whether a
push carries code, not whether the change was planned:

- A small **code** change (a one-line fix, a small tweak) is still a code-bearing push, so set
  its bookmark through the bundled review gate — it blocks only confirmed critical findings,
  and a one-liner can still be wrong.
- A **non-code** change (a typo, a comment, a doc tweak) has no code to review, so it skips the
  gate too, like any docs-only push.

Reserve this for changes that are genuinely small; if something starts small but turns into real
feature work, fold it back into the full workflow.
