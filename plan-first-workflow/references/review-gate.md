# The code review gate

This skill bundles its own critical-only blocking review gate. Use it for every **code-bearing** bookmark
push (Implementation in Phase 4, and any later code fix in Phase 5) — never run
`jj bookmark set` directly for those. Docs-only pushes (the plan and its revisions) skip this
gate; see the table in `references/jj-mechanics.md`.

The gate runs an independent, read-only Codex code review over the reviewed commit's diff, then
sets the bookmark only when a valid result has no `critical` findings.

## Workflow

1. Finish the code changes and snapshot the working copy with `jj status`.
2. Run `scripts/review-and-bookmark.sh <bookmark> [revision]` with escalated sandbox permissions
   on the first attempt. The revision defaults to `@`.
3. Let the script run the read-only `codex exec` review and parse its structured findings.
4. Report every finding. A `critical` finding fails the gate and blocks the bookmark and push;
   `high`, `medium`, and `low` findings are report-only and do not block them.
5. Review execution or result-parsing failures also fail closed. A valid critical result is a
   completed review, not an execution failure: the script exits with status 3 and must not be
   retried automatically.
6. When the valid result has no `critical` findings, the script sets
   `jj bookmark set <bookmark> -r <revision>` for you. Then `jj git push` to update the PR. After
   either outcome, only report the result; do not modify files or rerun review in response to
   findings.

## Rework authorization

Review findings never authorize file changes. Findings-driven rework requires a new, explicit
user request after the findings have been reported. One authorization covers only the requested
edits and one subsequent review; new findings require another explicit request before further
rework.

The original implementation request and instructions such as "finish", "proceed", or "push" do
not authorize findings-driven rework. Do not ask to rework: report the findings, then continue
the requested push after a pass or stop after a critical gate failure. Normal forward work
requested by the user is not findings-driven rework and is reviewed normally.

## Execution permissions

The script launches a nested `codex exec` process. That process needs network access and write
access to `$CODEX_HOME` to initialize its app-server client, even though the review itself uses a
read-only sandbox. A normal workspace sandbox blocks that initialization.

Use `exec_command` with `sandbox_permissions: "require_escalated"` on the first attempt — do not
run it in the workspace sandbox first. Ask for approval with a concise justification such as
"Allow the independent Codex review gate to access its runtime state and network?" and request
this narrow reusable prefix rule:

```text
[".agents/skills/plan-first-workflow/scripts/review-and-bookmark.sh"]
```

If escalation is declined or the escalated command fails, treat the gate as failed and do not
mutate the bookmark. Do not interpret a successful Codex process exit as a valid review until the
structured `findings` array has been parsed. Review execution and schema validity remain
mandatory; after parsing, the script deterministically fails the gate only for `critical`
findings.

## Command

From the repository root:

```bash
.agents/skills/plan-first-workflow/scripts/review-and-bookmark.sh <bookmark> [revision]
```

Examples:

```bash
.agents/skills/plan-first-workflow/scripts/review-and-bookmark.sh feat/windows-overlay @
.agents/skills/plan-first-workflow/scripts/review-and-bookmark.sh fix/hotkey-timeout @-
```

The review is capped at 300s by default; override with `JJ_REVIEW_TIMEOUT_SECONDS`. Invoke the
script with a tool timeout larger than that cap (e.g. 330s) so the script's own watchdog reports
a clean timeout before the outer call is killed.

The script stores local review reports and the captured diff under `.git/jj-reviews/`. Do not add
these files to the repository.

## Scope

The script handles the normal single-target flow: `jj bookmark set NAME -r REVISION`. If a
bookmark operation can't be represented that way, stop and explain that the gate script must be
extended; do not fall back to an unreviewed bookmark command.
