# Version control mechanics (jj) & the review gate

Shared by several phases. Read this when a phase file sends you here.

## jj is the primary interface

Jujutsu (`jj`) is the primary local interface. Git branches exist only as the remote review
artifacts created from `jj` bookmarks — do not start feature work with `git checkout -b`, and do
not use `git commit` / ad-hoc `git push` for review branches.

Every reviewable change needs a non-empty description and is shared by moving a named bookmark
onto it and pushing that bookmark:

```bash
jj git fetch --remote origin                          # start from the latest base
# ... edit files in the working-copy change @ ...
jj describe -m "type(scope): concise summary"         # describe (never leave blank)
jj bookmark set <bookmark> -r @                        # point the bookmark at @  (but see gate below)
jj git push --remote origin --bookmark <bookmark>      # push (creates/updates the branch)
gh pr create --draft --base <base> --head <bookmark>   # Planning: open the draft PR
gh pr ready <pr-number>                                # Finishing: after implementation only
```

Reuse the **same** bookmark while iterating on one review thread. After adding child changes
with `jj new`, move the bookmark forward (`jj bookmark set <bookmark> -r @`) and re-push. If a
push safety check fails, `jj git fetch` first, then push again.

## When to route through the review gate

This skill bundles its own advisory Codex **code** review gate. It applies to pushes that carry
code and not to design-doc pushes:

| Push | Gate? | How to set the bookmark |
| --- | --- | --- |
| Plan draft (Phase 2) and plan revisions (Phase 3) — docs only | **No** | `jj bookmark set <bookmark> -r @` directly |
| Implementation (Phase 4) and any later code fix (Phase 5) | **Yes** | via the bundled gate script |
| Merge / post-merge re-sync (Phase 6) | **No** | no bookmark mutation on code |

For a code-bearing push, don't run `jj bookmark set` yourself. Run
`scripts/review-and-bookmark.sh <bookmark>`: it reviews the diff, reports advisory findings, and
sets the bookmark for you. Then run `jj git push` to update the PR. The gate's full operation —
escalated sandbox permissions, timeout, the findings-driven rework cap, and its fail-closed
semantics — is documented in `references/review-gate.md`.
