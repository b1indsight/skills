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
- The project's documentation entry points and the current README, architecture, reference,
  examples, and changelog material closest to the requested behavior. Read
  `references/documentation.md` and use its impact map rather than assuming every document type
  must change.
- The project's actual base branch. Read it from repository instructions or infer it from CI and
  repository configuration; use `main` only when the project identifies it as the base.

Before editing the plan, establish the task's exact starting point:

1. Run `jj git fetch --remote origin`.
2. Resolve the latest `<base>@origin` and confirm it is the intended project base.
3. Create a new plan change directly on that commit:
   `jj new <base>@origin -m "docs(plan): describe <feature>"`.
4. Confirm the new plan change's parent is exactly `<base>@origin` with `jj status` or `jj log`.

Do not reuse the current `@` merely because it is available: it may be an old base or an unrelated
task. Creating the plan change from `<base>@origin` preserves an unrelated working-copy change as a
separate head; never squash, abandon, or rebase that work into the new task. If `@` is already an
empty task-specific plan change whose parent is the latest `<base>@origin`, describe and reuse it
instead of creating a duplicate.

## 2. Write the plan and open a draft PR

Write an implementation plan as a design doc — enough for the user to judge the approach
without reading code:

- The technical approach and the main choices behind it
- The file / module layout and where new code lands
- The natural boundaries of the proposed change stack: each independently explainable and
  revertible functional outcome, its dependencies, and the tests and documentation that belong
  with it
- The test strategy (what proves it works)
- A documentation-impact section that lists the current-truth docs, examples, changelog, indexes,
  or generators expected to change — or gives a concrete reason no project documentation should
  change

This produces **a plan only — no product or test code yet.** Keep the plan in the dedicated change
created from the latest base, put that change on a new review-friendly named bookmark
(`feat/<slug>`, `fix/<slug>`, `docs/<slug>`), push it, and open a **draft** PR. The plan is the
cheapest artifact to change, and reviewing it before code exists is where course-corrections are
nearly free. The proposed change stack is a review aid, not a fixed count or a demand for one
change per implementation step. Combine steps that lack standalone review or rollback value, and
never preserve a deliberately broken intermediate state just to create another change.

Apart from the plan itself and any index entry required to make it discoverable, do not update
current-truth documentation during Planning to present the proposed behavior as already available.
Synchronize that documentation with actual behavior during Implementation.

This push carries a design doc, not code, so set the bookmark directly — it does **not** go
through this skill's code review gate. See `references/jj-mechanics.md` for the exact commands.

## Then

Go to `references/approval-gate.md` and stop. Do not start writing tests or implementation code.
