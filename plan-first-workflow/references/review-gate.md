# The code review gate

This skill bundles its own advisory review gate. Use it for every **code-bearing** bookmark
push (Implementation in Phase 4, and any later code fix in Phase 5) — never run
`jj bookmark set` directly for those. Docs-only pushes (the plan and its revisions) skip this
gate; see the table in `references/jj-mechanics.md`.

The gate runs an independent, read-only Codex code review over the reviewed commit's diff, then
sets the bookmark for you after any valid result.

## Workflow

1. Finish the code changes and snapshot the working copy with `jj status`.
2. Run `scripts/review-and-bookmark.sh <bookmark> [revision]` with escalated sandbox permissions
   on the first attempt. The revision defaults to `@`.
3. Let the script run the read-only `codex exec` review and parse its structured findings.
4. **Findings are advisory only.** If review produces findings, report them to the user, but do
   not block the bookmark or the push and do not force the change back for mandatory rework
   (不打回). The user may choose to iterate, subject to the rework cap below.
5. If review execution or result parsing fails, treat the review as failed. Stop, report the
   error, and do not mutate the bookmark. These are the *only* conditions that block the push.
6. After any successfully parsed result — including a non-empty findings array — the script sets
   `jj bookmark set <bookmark> -r <revision>` for you. Then `jj git push` to update the PR.

## Rework limit

This cap targets **findings-driven rework only**, not normal development. A rework pass is when
you revise the change *solely to satisfy the previous review's findings* and then review again.
Run **at most 3 findings-driven review passes** on the same change; once three have run, stop
reviewing, report the final result, and proceed. The cap exists because chasing findings
otherwise tends to hunt for problems without limit.

The cap does **not** restrict reviews of normal forward work. A review prompted by a new
requested change, continued development, or a fix unrelated to the prior findings is not rework
— it doesn't count against the cap, even though `jj` keeps the same change id across edits.

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
structured `findings` array has been parsed — findings are advisory, but review execution and
schema validity remain mandatory.

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
