---
name: plan-first-workflow
description: Plan and deliver a feature or non-trivial repository change through explicit plan approval and implementation on one bookmark and PR. Use when the project follows the plan-first workflow; route small changes through its lightweight path.
---

# Plan-First Feature Workflow

Choose the current phase below and read only its reference. Load shared references when that
phase needs them.

## Always apply

- Write code in English, including identifiers, comments, and docstrings.
- Every commit message and every PR title must follow Conventional Commits:
  - Use `type: description` for the commit subject or PR title. Choose the type by what changed: `feat` for a new feature (`feat: add CSV export`), `fix` for a bug fix, and `docs` for documentation only.
  - Add an optional scope in parentheses to name the affected component, as in `fix(parser): handle empty input`. A draft plan PR title might be `docs(plan): outline CSV export`.
  - For a breaking change, put `!` immediately before the colon, as in `feat(api)!: require an access token`, or add a `BREAKING CHANGE: <description>` footer to the commit message. Use `!` in the PR title when the PR introduces a breaking change.
  - Write the commit subject and any commit body in English. Separate the optional body from the subject with a blank line.
- At project startup, run `jj root`. Reuse the workspace if it exists. If the project has no jj workspace, run `jj git init --colocate` at the project root (the checkout root for an existing Git repository) so `jj` and `git` share the same working tree. Confirm `jj status` succeeds before continuing.
- **One feature = one feature-record document = one bookmark = one PR.** The draft plan PR
  becomes the implementation PR; never open a second implementation PR or merge/close the
  plan PR to start fresh.
- The first draft commit contains only the plan, including demo code and its expected result. Do not write tests or production code before explicit user approval.
- For a trivial or very small change, read [the small-change path](references/small-changes.md)
  first. It skips planning; code-bearing pushes still require the review gate.

## Choose the current phase

| Current state | Read |
| --- | --- |
| A feature or non-trivial change is requested; no plan PR exists | [Planning (1)](references/plan.md) |
| The draft plan PR is open; explicit approval is pending | [Approval gate (2)](references/approval-gate.md) |
| The user approved the plan; implementation is in progress | [Implementation (3)](references/implement.md) |
| Implementation is pushed; validation, readiness, or merge remains | [Finishing (4-5)](references/finish.md) |

## Supporting references

- When creating or updating the feature record, read [document rules](references/feature-record.md)
  and use [the template](assets/feature-record-template.md).
- Before version-control operations, read [Jujutsu mechanics](references/jj-mechanics.md).
- Before publishing, follow [the workflow review routing](references/review-gate.md). Any documentation-only push skips the automated code review gate; a push containing code or tests uses the standalone [jj-review-gate subskill](../jj-review-gate/SKILL.md).
