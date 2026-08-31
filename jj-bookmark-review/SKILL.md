---
name: jj-bookmark-review
description: Run an independent Codex code review before creating, setting, moving, or advancing a Jujutsu bookmark; critical findings block the bookmark, while other valid results allow it. Use whenever a task would execute `jj bookmark create`, `jj bookmark set`, `jj bookmark move`, or `jj bookmark advance` after code generation or modification in this repository.
---

# JJ Bookmark Review

Run the bundled critical-only blocking review before changing a Jujutsu bookmark. Never execute a
bookmark-mutating `jj` command directly when this skill applies.

## Workflow

1. Finish code generation and snapshot the working copy with `jj status`.
2. Run `scripts/review-and-bookmark.sh <bookmark> [revision]` with escalated
   sandbox permissions on the first attempt. The revision defaults to `@`.
3. Let the script run an independent, read-only `codex exec` review and parse its
   structured findings.
4. Report every finding, but use severity only to decide the gate: `critical` findings block the
   bookmark and requested push; `high`, `medium`, and `low` findings are report-only and do not
   block them.
5. If review execution or result parsing fails, treat the review as technically failed. Stop,
   report the error, and do not mutate the bookmark. A valid review with a `critical` finding is
   a completed review that failed the gate, not an execution failure; the script exits with
   status 3 and must not be retried automatically.
6. When the valid result has no `critical` findings, let the script run
   `jj bookmark set <bookmark> -r <revision>`. After either a pass or a critical failure, only
   report the result; do not modify files or rerun review in response to findings.

## Rework authorization

Review findings never authorize file changes. Findings-driven rework requires a new, explicit
user request after the findings have been reported. One authorization covers only the requested
edits and one subsequent review; findings from that review are again report-only and require
another explicit user request before any further rework.

The original implementation request and instructions such as "finish", "proceed", or "push" do
not authorize findings-driven rework. Do not ask to rework: report the findings, then continue
the requested push after a pass or stop after a critical gate failure.

Normal forward work requested by the user, continued feature development, and fixes unrelated
to prior findings are not findings-driven rework. Review them normally when the bookmark next
moves.

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
structured `findings` array has been parsed. Review execution and schema validity remain
mandatory; after parsing, the script deterministically fails the gate only for `critical`
findings.

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

The review is capped at 180s by default; override with the
`JJ_REVIEW_TIMEOUT_SECONDS` environment variable. Invoke the script with a tool
timeout larger than that cap (e.g. 210s) so the script's own watchdog reports a
clean timeout before the outer call is killed.

The script stores local review reports and the captured diff under
`.git/jj-reviews/`. Do not add these files to the repository.

## Scope

Use the script for the repository's normal single-target review flow. If the
requested bookmark operation cannot be represented by `jj bookmark set NAME -r
REVISION`, stop and explain that the gate script must be extended; do not fall
back to an unreviewed bookmark command.
