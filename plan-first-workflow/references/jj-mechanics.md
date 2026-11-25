# Version control mechanics (jj) & the review gate

Shared by several phases. Read this when a phase file sends you here.

## jj is the primary interface

Jujutsu (`jj`) is the primary local interface. Git branches exist only as the remote review
artifacts created from `jj` bookmarks — do not start feature work with `git checkout -b`, and do
not use `git commit` / ad-hoc `git push` for review branches.

For the documentation-only draft, set `base` and `bookmark` to the base branch and feature bookmark. Set `feature` to the actual feature name, `repo_url` to the repository's GitHub web URL (without `.git` or a trailing slash), and `plan_path` to the URL-encoded repository-relative path of the feature record. Use the project's required GitHub CLI wrapper in place of `gh` where applicable.

```bash
jj git fetch --remote origin
# Prepare the plan on the confirmed base; verify @ contains only documentation.
jj describe -m "docs: plan $feature"
jj bookmark set "$bookmark" -r @
jj git push --remote origin --bookmark "$bookmark"
plan_commit=$(jj log --no-graph -r "$bookmark" -T commit_id)
gh pr create --draft --base "$base" --head "$bookmark" \
  --title "Plan: $feature" --body "Review the [$feature plan]($repo_url/blob/$plan_commit/$plan_path) before implementation."
```

Keep the PR in draft through approval and implementation. Publish code using the reviewed-commit sequence below, not the draft's direct bookmark command. If a push safety check fails, fetch and inspect the remote state before retrying.

Only after [final validation](finish.md), mark the same PR ready using its number:

```bash
gh pr ready "$pr_number"
```

## When to route through the review gate

This workflow uses the standalone `jj-review-gate` skill for critical-only blocking Codex
**code** review. Route each push as follows:

| Push | Gate? | How to set the bookmark |
| --- | --- | --- |
| First plan and documentation-only revisions before approval | **No** | Set the bookmark directly as in the draft example above |
| Documentation-only push after approval (e.g., a timeline update) | **No** | Publish a separate documentation commit directly on the current remote bookmark tip, as described below |
| Any push containing code or tests, even alongside documentation | **Yes** | after a pass, set it to the returned reviewed commit ID |
| Merge / post-merge re-sync (Phase 5) | **No** | no bookmark mutation on code |

After approval, publish any standalone documentation update before starting the next implementation child. The **entire outgoing range** from the remote bookmark must contain only documentation, not just the tip commit. Never advance the bookmark to a documentation child of unpublished code. If implementation is already in progress, either include the docs in its gated push or put the docs in a separate child of the published tip, push only that child, then rebase the unpublished implementation onto it. Review the resulting implementation revision before moving the bookmark to its exact reviewed ID; a review of the pre-rebase ID does not transfer.

For a push that requires review, first run the shared review gate. It returns the exact reviewed commit
ID on stdout only after a pass. The workflow then sets and pushes the bookmark:

```bash
if reviewed_commit=$(.agents/skills/plan-first-workflow/scripts/review.sh @); then
  jj bookmark set <bookmark> -r "$reviewed_commit" --ignore-working-copy &&
    jj git push --remote origin --bookmark <bookmark>
fi
```

Run the review with the escalated permissions required by the subskill. A nonzero review exit
stops the sequence; never set or push the bookmark after a failure. Do not substitute `@` for
`$reviewed_commit` when setting the bookmark, or a later snapshot could publish unreviewed code.
The review gate's execution rules and findings-driven rework authorization are documented in
[review-gate.md](review-gate.md).
