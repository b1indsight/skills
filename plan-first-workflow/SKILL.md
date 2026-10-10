---
name: plan-first-workflow
description: Plan and deliver a feature or non-trivial repository change through explicit plan approval and implementation on one bookmark and PR. Use when the project follows the plan-first workflow; route small changes through its lightweight path.
---

# Plan-First Feature Workflow

Choose the current phase below and read only its reference. Load shared references when that
phase needs them.

## Always apply

- **One feature = one feature-record document = one bookmark = one PR.** The draft plan PR
  becomes the implementation PR; never open a second implementation PR or merge/close the
  plan PR to start fresh.
- Do not write tests or implementation code before explicit user approval of the plan.
- For a trivial or very small change, read [the small-change path](references/small-changes.md)
  first. It skips planning; code-bearing pushes still require the review gate.

## Choose the current phase

| Current state | Read |
| --- | --- |
| A feature or non-trivial change is requested; no plan PR exists | [Planning (1–2)](references/plan.md) |
| The draft plan PR is open; explicit approval is pending | [Approval gate (3)](references/approval-gate.md) |
| The user approved the plan; implementation is in progress | [Implementation (4)](references/implement.md) |
| Implementation is pushed; validation, readiness, or merge remains | [Finishing (5–6)](references/finish.md) |

## Supporting references

- When creating or updating the feature record, read [document rules](references/feature-record.md)
  and use [the template](assets/feature-record-template.md).
- Before version-control operations, read [Jujutsu mechanics](references/jj-mechanics.md).
- Before a code-bearing bookmark push, read [the workflow review routing](references/review-gate.md)
  and use the standalone [jj-review-gate subskill](../jj-review-gate/SKILL.md).
