# The code review gate

This skill bundles its own advisory review gate. Use it once for each **code-bearing bookmark
update** (Implementation in Phase 4, and any later code fix in Phase 5). Docs-only updates,
including the plan and its revisions, skip this gate; see `references/jj-mechanics.md`.

Each invocation runs one independent, read-only Codex review over the complete net diff being
uploaded: from this task's previous submitted bookmark state to the new target. The range may span
one or several cohesive changes. After any valid result, the script sets the local bookmark to the
exact reviewed target; the caller then pushes it once.

## Review range

The target is the optional revision argument and defaults to `@`. It must resolve to one commit.
The script resolves the previous task state in this order:

1. The exact remote bookmark `<bookmark>@<remote>`, where the remote defaults to `origin` and can
   be changed with `JJ_REVIEW_REMOTE`. This is the normal baseline and represents the last fetched
   or pushed state of this task.
2. For a first-ever push with no remote bookmark, an exact local bookmark that still points to a
   different prior task state.
3. If neither bookmark exists, the target's single parent.

If the baseline is missing, conflicted, resolves to several commits, or is ambiguous because a
local-only bookmark already points to the target, fail closed instead of reviewing an incomplete
range. The review input is one `jj diff --from <baseline> --to <target>`, so rewriting an earlier
submitted change is still reviewed as the net modification since the previous push.

## Workflow

1. Finish and validate the change stack, then snapshot the working copy with `jj status`.
2. Run `scripts/review-and-bookmark.sh <bookmark> [target]` once with escalated sandbox permissions
   on the first attempt.
3. Let the script pin the baseline and target, capture their net diff, run the read-only
   `codex exec` review, and parse its structured suggestions.
4. **Suggestions are advisory only.** Report every suggestion to the user, but do not block the
   bookmark or push and do not force mandatory rework (不打回). The user may choose to iterate,
   subject to the cap below.
5. If range resolution, diff capture, review execution, or result parsing fails, stop, report the
   error, and do not mutate the bookmark. These are the only conditions that block submission.
6. After any valid result — including a non-empty suggestions array — the script sets
   `jj bookmark set <bookmark> -r <target>` to the exact reviewed commit.
7. Run one `jj git push` to update the PR.

## Rework limit

This cap targets **suggestions-driven rework only**, not normal development. A rework pass is when
you revise the submission batch solely in response to the previous review's suggestions and then
review the batch again. Run **at most 3 suggestions-driven review passes** for the same bookmark
update; once three have run, stop reviewing, report the final suggestions, and proceed. The cap
exists because chasing suggestions otherwise tends to hunt for problems without limit.

The cap does **not** restrict reviews of normal forward work. A review prompted by a new
requested change, continued development, or a fix unrelated to the prior suggestions is not
rework and does not count against the cap.

When permitted non-review work edits a submitted change, the next unified review still uses the
remote bookmark's previous state as its baseline, so one review covers the rewritten stack's net
modification. For user or reviewer feedback that evaluates the submitted PR — whether delivered
through GitHub or the conversation — do not rewrite a submitted change: put the work in a child
`fix` change and include it in the next unified bookmark review.

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
structured `findings` array has been parsed — that field carries advisory suggestions, while
review execution and schema validity remain mandatory.

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

Set `JJ_REVIEW_REMOTE` only when the task bookmark is pushed to a remote other than `origin`.

The script stores local review reports and the captured diff under `.git/jj-reviews/`. Do not add
these files to the repository.

## Scope

The script handles one bookmark update per invocation: one baseline, one target commit, one net
diff, one advisory review, and one `jj bookmark set NAME -r TARGET`. The target may be the tip of a
multi-change stack, but it must resolve to exactly one commit. If the update cannot be represented
that way, stop and explain that the gate script must be extended; do not fall back to an unreviewed
bookmark command.
