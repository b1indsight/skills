# Phase 1–2: Planning

You're here because a feature or non-trivial change was requested and no plan PR exists yet.
The goal of this phase is a reviewable plan — **not** any product or test code.

## 1. Orient

Before proposing anything, read what already exists:

- The project's own `AGENTS.md` / `CLAUDE.md` for the concrete facts this workflow deliberately
  leaves out: the base branch name, and the build / test / lint / packaging commands. Those are
  project facts, not workflow facts. If the project doesn't record them, ask the user or infer
  from the repo (CI config, `Cargo.toml` / `package.json`, etc.) rather than assuming.
- Any existing plan or design doc for this feature (projects often keep them under `docs/plan/`
  or similar). Build on it instead of duplicating it.
- The latest remote state, so you plan against the real base: `jj git fetch --remote origin`,
  then confirm the base with `jj status` or `jj log`.

## 2. Write the plan and open a draft PR

Write an implementation plan as a design doc — enough for the user to judge the approach
without reading code:

- The technical approach and the main choices behind it
- The file / module layout and where new code lands
- Step-by-step implementation order
- The test strategy (what proves it works)

This produces **a plan only — no product or test code yet.** Put the plan on a new,
review-friendly named bookmark (`feat/<slug>`, `fix/<slug>`, `docs/<slug>`), push it, and open
a **draft** PR. The plan is the cheapest artifact to change, and reviewing it before code
exists is where course-corrections are nearly free.

This push carries a design doc, not code, so set the bookmark directly — it does **not** go
through this skill's code review gate. See `references/jj-mechanics.md` for the exact commands.

## Then

Go to `references/approval-gate.md` and stop. Do not start writing tests or implementation code.
