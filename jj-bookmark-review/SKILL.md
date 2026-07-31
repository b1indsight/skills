---
name: jj-bookmark-review
description: Run an independent advisory Codex code review before creating, setting, moving, or advancing a Jujutsu bookmark, then set the bookmark after any valid review result. Use whenever a task would execute `jj bookmark create`, `jj bookmark set`, `jj bookmark move`, or `jj bookmark advance` after code generation or modification in this repository.
---

# JJ Bookmark Review

Run the bundled advisory review before changing a Jujutsu bookmark. Never execute a
bookmark-mutating `jj` command directly when this skill applies.

## Workflow

1. Finish code generation and snapshot the working copy with `jj status`.
2. Run `scripts/review-and-bookmark.sh <bookmark> [revision]` with escalated
   sandbox permissions on the first attempt. The revision defaults to `@`.
3. Let the script run an independent, read-only `codex exec review` and parse its
   structured findings.
4. If review produces findings, report them to the user but do not block the
   bookmark or the requested push. The user decides whether a finding requires
   another iteration on the same change.
5. If review execution or result parsing fails, treat the review as failed. Stop,
   report the error, and do not mutate the bookmark.
6. After any successfully parsed review result, including a non-empty findings
   array, let the script run `jj bookmark set <bookmark> -r <revision>`.

## Execution permissions

The script launches a nested `codex exec` process. That process needs network
access and write access to `$CODEX_HOME` to initialize its app-server client,
even though the review itself uses a read-only sandbox. A normal workspace
sandbox blocks that initialization.

Use `exec_command` with `sandbox_permissions: "require_escalated"` on the first
attempt. Do not run the script in the workspace sandbox first. Ask for approval
with a concise justification such as "Allow the independent Codex review gate
to access its runtime state and network?" and request this narrow reusable
prefix rule:

```text
[".agents/skills/jj-bookmark-review/scripts/review-and-bookmark.sh"]
```

If escalation is declined or the escalated command fails, treat the gate as
failed and do not mutate the bookmark.

Do not interpret a successful Codex process exit as a valid review until the
structured `findings` array has been parsed. Findings are advisory; review
execution and schema validity remain mandatory.

## Command

From the repository root:

```bash
.agents/skills/jj-bookmark-review/scripts/review-and-bookmark.sh <bookmark> [revision]
```

Examples:

```bash
.agents/skills/jj-bookmark-review/scripts/review-and-bookmark.sh feat/tray @
.agents/skills/jj-bookmark-review/scripts/review-and-bookmark.sh fix/audio @-
```

The script stores local review reports under `.git/jj-reviews/`. Do not add
these reports to the repository.

## Scope

Use the script for the repository's normal single-target review flow. If the
requested bookmark operation cannot be represented by `jj bookmark set NAME -r
REVISION`, stop and explain that the gate script must be extended; do not fall
back to an unreviewed bookmark command.
