# Version control mechanics (jj) & the review gate

Shared by several phases. Read this when a phase file sends you here.

## jj is the primary interface

Jujutsu (`jj`) is the primary local interface. Git branches exist only as the remote review
artifacts created from `jj` bookmarks — do not start feature work with `git checkout -b`, and do
not use `git commit` / ad-hoc `git push` for review branches.

For the documentation-only draft, set `base` to the project's base branch and `bookmark` to the feature bookmark. Use the project's required GitHub CLI wrapper in place of `gh` where applicable.

```bash
jj git fetch --remote origin
# Prepare the plan on the confirmed base; verify @ contains only documentation.
jj describe -m "docs: plan the feature"
jj bookmark set "$bookmark" -r @
jj git push --remote origin --bookmark "$bookmark"
gh pr create --draft --base "$base" --head "$bookmark" --fill
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
| Documentation-only push after approval (e.g., a timeline update) | **No** | Set the bookmark directly and push it to the existing PR |
| Any push containing code or tests, even alongside documentation | **Yes** | after a pass, set it to the returned reviewed commit ID |
| Merge / post-merge re-sync (Phase 5) | **No** | no bookmark mutation on code |

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
