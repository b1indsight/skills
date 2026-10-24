# Phase 1–2: Planning

You're here because a feature or non-trivial change was requested and no plan PR exists yet.
The goal is the initial plan in a feature-record document — **not** any product or test code.

## 1. Orient

### 1. Rules to follow

- **Project-specific facts.** The base branch name and the build / test / lint / packaging
  commands are project facts, not workflow facts. This workflow deliberately leaves them to the
  project. If the project doesn't record them, ask the user or infer from the repo.
- **Existing documents.** Extend any existing plan, feature-record, or design doc for this
  feature in place instead of duplicating it; retain its original plan and append the change
  timeline.
- **Latest remote state.** Plan against the latest remote state so you use the real base.

### 2. Execution steps

1. **Fetch updates and confirm the base.** Fetch the latest remote state with
   `jj git fetch --remote origin`, then confirm the base with `jj status` or `jj log`.
2. **Read project guidance.** Read the project's own `AGENTS.md` / `CLAUDE.md` for the base
   branch name and the build / test / lint / packaging commands. If the project doesn't record
   them, ask the user or infer from the repo (CI config, `Cargo.toml` / `package.json`, etc.)
   rather than assuming.
3. **Read existing feature documents.** Read any existing plan, feature-record, or design doc
   for this feature. Extend it in place instead of duplicating it; retain its original plan
   and append the change timeline.

### 3. Checks to run

- [ ] 是否同步到正确的基准状态
- [ ] 是否阅读相关文档，完整了解当前的代码结构，相关定义与现有流程
- [ ] 是否准确了解事实，不确定的事和决策均询问过

## 2. Fill the feature-record template and open a draft PR

For a new document, copy [the outline template](../assets/feature-record-template.md) and fill its
RFC-inspired initial-plan sections: motivation and goals, proposed behavior, technical design,
alternatives and rationale, costs and risks, implementation order, and validation criteria.
Use concrete examples and explain why the proposed complexity is justified over simpler options.
Separate questions that block approval from those to resolve during implementation.
Scale detail to the task; explain sections that do not apply instead of inventing content.
The plan should let the user judge the approach without reading code.

Plan ablation comparisons now, but run them after implementation and before automated code
review. Leave the timeline empty until an actual requirement update, change, or decision occurs.
For an existing plan, preserve its text and add the timeline section; fill only missing planning
details needed to review this work. Follow the [document rules](feature-record.md).

This produces **documentation only — no product or test code yet.** Put the feature-record document
on a new, review-friendly named bookmark (`feat/<slug>`, `fix/<slug>`, `docs/<slug>`), push it, and open
a **draft** PR. The plan is the cheapest artifact to change, and reviewing it before code
exists is where course-corrections are nearly free.

This push carries a design doc, not code, so set the bookmark directly — it does **not** go
through this skill's code review gate. See [jj-mechanics.md](jj-mechanics.md) for the exact commands.

## Then

Go to [approval-gate.md](approval-gate.md) and stop. Do not start writing tests or implementation code.
