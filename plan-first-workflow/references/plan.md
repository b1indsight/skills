# Phase 1: Planning

You're here because a feature or non-trivial change was requested and no plan PR exists yet.
The goal is the initial plan in a feature-record document — **not** any product or test code.

## 1. Rules to follow

- **Project-specific facts.** The base branch name and the build / test / lint / packaging
  commands are project facts, not workflow facts. This workflow deliberately leaves them to the
  project. If the project doesn't record them, ask the user or infer from the repo.
- **Existing documents.** Extend any existing plan, feature-record, or design doc for this
  feature in place instead of duplicating it; retain its original plan and append the change
  timeline.
- **Latest remote state.** Plan against the latest remote state so you use the real base.
- **Reviewable plan.** Use concrete examples and explain why the proposed complexity is justified
  over simpler options. Separate questions that block approval from those to resolve during
  implementation. Scale detail to the task; explain sections that do not apply instead of
  inventing content. The plan should let the user judge the approach without reading code.
- **Feature-record history.** Leave the timeline empty until an actual requirement update,
  change, or decision occurs. For an existing plan, preserve its text and add the timeline
  section; fill only missing planning details needed to review this work. Follow the
  [document rules](feature-record.md).
- **Documentation only.** This produces **documentation only — no product or test code yet.**
- **Docs-only publication.** This push carries a design doc, not code, so set the bookmark
  directly — it does **not** go through this skill's code review gate. See
  [jj-mechanics.md](jj-mechanics.md) for the exact commands.

## 2. Execution steps

1. **Fetch updates and confirm the base.** Fetch the latest remote state with
   `jj git fetch --remote origin`, then confirm the base with `jj status` or `jj log`.
2. **Read project guidance.** Read the project's own `AGENTS.md` / `CLAUDE.md` for the base
   branch name and the build / test / lint / packaging commands. If the project doesn't record
   them, ask the user or infer from the repo (CI config, `Cargo.toml` / `package.json`, etc.)
   rather than assuming.
3. **Read existing feature documents.** Read any existing plan, feature-record, or design doc
   for this feature. Extend it in place instead of duplicating it; retain its original plan
   and append the change timeline.
4. **Fill the feature-record template.** For a new document, copy
   [the outline template](../assets/feature-record-template.md) and fill its RFC-inspired
   initial-plan sections: motivation and goals, proposed behavior, technical design,
   alternatives and rationale, costs and risks, implementation order, and validation criteria.
   Plan ablation comparisons now, but run them after implementation and before automated code
   review.
5. **Open a draft PR.** Put the feature-record document on a new, review-friendly named bookmark
   (`feat/<slug>`, `fix/<slug>`, `docs/<slug>`), push it, and open a **draft** PR. The plan is the
   cheapest artifact to change, and reviewing it before code exists is where course-corrections
   are nearly free.

## 3. Checks to run

- [ ] Have you synchronized to the correct base state?
- [ ] Have you read the relevant documentation and fully understood the current code structure,
  related definitions, and existing workflows?
- [ ] Have you accurately understood the facts and asked the user about all uncertainties
  and decisions?
- [ ] Does the feature record contain a reviewable initial plan and the planned validation
  and ablation comparisons?
- [ ] Is the feature-record document published in a docs-only draft PR on the feature's bookmark,
  with no product or test code included?

## Then

Go to [approval-gate.md](approval-gate.md) and stop. Do not start writing tests or implementation code.
