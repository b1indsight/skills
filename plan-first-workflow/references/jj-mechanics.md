# Version control mechanics (jj) & the review gate

Shared by several phases. Read this when a phase file sends you here.

## jj is the primary interface

Use `jj` locally. `@` is a working-copy commit: edits are snapshotted without `git add`, `jj describe` sets its message, and `jj new` starts a child without advancing its parent's bookmark. Push the named bookmark to publish a Git branch for the PR. Git branches exist only as remote review artifacts of `jj` bookmarks: do not start feature work with `git checkout -b`, and do not use `git commit` or ad-hoc `git push` for review branches. Reuse the same bookmark for every push to this feature's PR; move it forward rather than creating another.

For the documentation-only draft, set `base` and `bookmark` to the base branch and feature bookmark. Set `feature` to the actual feature name, `repo_url` to the repository's GitHub web URL (without `.git` or a trailing slash), and `plan_path` to the URL-encoded repository-relative path of the feature record. Use the project's required GitHub CLI wrapper in place of `gh` where applicable.

```bash
jj git fetch --remote origin
jj status
jj new "${base}@origin"
# Write the feature record, then inspect the working-copy patch before publishing.
jj diff -r @
jj describe -m "docs: plan $feature"
jj bookmark create "$bookmark" -r @
jj git push --remote origin --bookmark "$bookmark"
plan_commit=$(jj log --no-graph -r "$bookmark" -T commit_id)
gh pr create --draft --base "$base" --head "$bookmark" \
  --title "docs(plan): outline $feature" --body "Review the [$feature plan]($repo_url/blob/$plan_commit/$plan_path) before implementation."
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
| Any documentation-only push, before or after approval | **No** | Create the bookmark for the first draft; for later revisions move the existing bookmark to the documentation tip |
| Any push containing code or tests, even alongside documentation | **Yes** | after a pass, set it to the returned reviewed commit ID |
| Merge / post-merge re-sync (Phase 5) | **No** | no bookmark mutation on code |

Classify the entire outgoing range, not just the tip. If implementation is in progress, either include the docs in its review or publish the docs separately. For separate publication, first consolidate any unpublished implementation stack into one change and save its identity while it is still `@`:

```bash
implementation_change=$(jj log -r @ --no-graph -T change_id)
```

Start the documentation change from the published feature tip:

```bash
jj git fetch --remote origin
jj new "${bookmark}@origin"
# Edit only the documentation.
jj describe -m "docs: update $feature"
jj log -r "${bookmark}@origin..@" --summary
# Proceed only if every outgoing change is documentation-only.
jj bookmark set "$bookmark" -r @
jj git push --remote origin --bookmark "$bookmark"
```

If you saved an implementation change, resume it after the documentation push:

```bash
jj rebase -r "$implementation_change" -d "${bookmark}@origin"
jj edit "$implementation_change"
jj status
```

Resolve any listed conflicts and rerun affected checks before review. Approval of a previous commit ID does not cover the rebased code.

The gate reviews one commit against its parent. For a code-bearing push, prepare one non-merge commit directly on the published feature tip (on the remote base for a new small-change PR). Squash any unpublished stack first; never rewrite published commits. Set `parent` to `${bookmark}@origin` for an existing PR or `${base}@origin` for a new one. Describe the implementation before capturing its ID: changing its description later requires another review.

```bash
set -e
jj git fetch --remote origin
jj describe -m "${change_summary:?Set a nonempty implementation description}"
candidate=$(jj log --no-graph -r "(@ & children($parent)) ~ (merges() | conflicts())" -T commit_id)
test -n "$candidate" || { echo 'Expected one conflict-free change directly on the published parent.' >&2; exit 1; }
reviewed_commit=$(.agents/skills/plan-first-workflow/scripts/review.sh "$candidate")
test "$reviewed_commit" = "$candidate"
jj bookmark set "$bookmark" -r "$reviewed_commit" --ignore-working-copy
jj git push --remote origin --bookmark "$bookmark"
```

Run the review with the escalated permissions required by the subskill. A nonzero review exit
stops the sequence; never set or push the bookmark after a failure. Do not substitute `@` for
`$reviewed_commit` when setting the bookmark, or a later snapshot could publish unreviewed code.
The review gate's execution rules and findings-driven rework authorization are documented in
[review-gate.md](review-gate.md).
