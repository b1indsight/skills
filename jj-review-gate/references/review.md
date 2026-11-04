# Review execution

Read this file before running the bundled review gate. The authorization rules in
[SKILL.md](../SKILL.md) always apply. No plan document, plan approval, or PR is required
for standalone use.

The gate reviews one target commit's diff in an independent, read-only Codex process.
That coordinator launches two child agents in parallel: functionality/security and complexity.
Both read the same captured diff; the coordinator waits for both and consolidates their findings.
It reports the result without changing source files, setting bookmarks, or pushing changes.

## Workflow

1. Finish the code changes before review. The script snapshots the working copy with
   `jj status` and resolves the requested revision to exactly one commit.
2. Run `scripts/review.sh [revision]` with escalated sandbox permissions on the first attempt.
   The revision defaults to `@`.
3. Let the script run the read-only `codex exec` coordinator. It enables native multi-agent
   support for this invocation, caps child concurrency at two, and prevents grandchildren.
   Both children must be launched before waiting for either; each receives its assignment,
   shared review rules, and the absolute path to the pinned diff.
4. Report every finding. A `critical` finding fails the gate; `high`, `medium`, and `low`
   findings are report-only.
5. Execution or result-parsing failures fail closed. The structured result must mark both
   `reviews.functionality_security` and `reviews.complexity` as `complete`; missing or incomplete
   reviews fail with status 65, while any available findings are still reported. Do not substitute
   a coordinator review for a failed child. A valid critical result is a completed review,
   not an execution failure: it exits with status 3 and must not be retried automatically.
6. On a pass, return exit status 0 and the exact reviewed commit ID on stdout. Findings,
   diagnostics, and report paths go to stderr. Failed reviews produce no stdout.
7. After either outcome, report the result. Do not modify files or rerun review in response
   to findings. Bookmark updates and pushes belong to the calling workflow and require its
   existing authorization; this skill does not perform them.

## Execution permissions

The script launches a nested `codex exec` process. That process needs network access and write
access to `$CODEX_HOME` to initialize its app-server client, even though the review itself uses a
read-only sandbox. A normal workspace sandbox blocks that initialization.

Use `exec_command` with `sandbox_permissions: "require_escalated"` on the first attempt — do not
run it in the workspace sandbox first. Ask for approval with a concise justification such as
"Allow the independent Codex review gate to access its runtime state and network?" and request
this narrow reusable prefix rule:

```text
[".agents/skills/jj-review-gate/scripts/review.sh"]
```

If escalation is declined or the escalated command fails, treat the gate as failed and stop. Do not interpret a successful Codex process exit as a valid review until the
structured `findings` array and both review completion states have been parsed. Review
execution, both completed child reviews, and schema validity remain mandatory; among
findings, only `critical` blocks the gate.

Native child agents need the parent's stored rollout. The invocation therefore does not use
`--ephemeral`: Codex may retain local parent and child session records under `$CODEX_HOME`.
Both children inherit the coordinator's read-only sandbox.

## Command

From the repository root:

```bash
.agents/skills/jj-review-gate/scripts/review.sh [revision]
```

Examples:

```bash
.agents/skills/jj-review-gate/scripts/review.sh @
.agents/skills/jj-review-gate/scripts/review.sh @-
```

The entire review, including the coordinator and both children, is capped at 600s by default;
override with `JJ_REVIEW_TIMEOUT_SECONDS`. Invoke the script with a tool timeout larger than
that cap (e.g. 660s) so the script's own watchdog reports a clean timeout before the outer call
is killed.

The script stores local review reports and the captured diff under `.git/jj-reviews/`. The nested
Codex transcript captured by the script is never forwarded to the caller: it is deleted after
both reviews complete with a valid result, and retained there when execution, either child review,
or result parsing fails. This does not delete Codex's own session records. Do not add these files
to the repository.

## Scope and caller contract

The script reviews the diff introduced by exactly one Jujutsu commit. A revision that resolves
to zero or multiple commits fails before review. It does not review an entire branch's aggregate
diff; choose the target that matches the caller's intended review scope.

On a pass, use the returned commit ID for any subsequent publication. Do not resolve a mutable
revision such as `@` again: the working copy may have changed since review. If source changes
are made after the review, review the new target before publishing it.
