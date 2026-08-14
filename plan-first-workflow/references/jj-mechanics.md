# Version control mechanics (jj) & the review gate

Shared by several phases. Read this when a phase file sends you here.

## jj is the primary interface

Jujutsu (`jj`) is the primary local interface. Git branches exist only as the remote review
artifacts created from `jj` bookmarks — do not start feature work with `git checkout -b`, and do
not use `git commit` / ad-hoc `git push` for review branches.

Every reviewable change needs a non-empty description. A feature's bookmark points to the tip of
its ordered change stack; pushing that one bookmark publishes the whole stack to the same PR:

```bash
jj git fetch --remote origin                          # refresh the declared project base
jj new <base>@origin -m "docs(plan): describe <feature>" # new task starts exactly here
# ... edit the plan in this dedicated change ...
jj bookmark set <bookmark> -r @                        # plan-only push; no code gate
jj git push --remote origin --bookmark <bookmark>      # push (creates/updates the branch)
gh pr create --draft --base <base> --head <bookmark>   # Planning: open the draft PR
# ... after explicit approval ...
jj new -m "type(scope): first functional outcome"      # new child; never code in the plan change
# ... write tests, implement, document, validate ...
jj new -m "type(scope): next functional outcome"       # only for another independent intent
# ... finish the final unit without creating an empty trailing change ...
# review the complete submission batch once (see below)
jj git push --remote origin --bookmark <bookmark>      # one push publishes the reviewed stack
gh pr ready <pr-number>                                # Finishing: after implementation only
```

For a brand-new task, never omit `<base>@origin` from `jj new` and accidentally inherit the
current unrelated `@`. Determine `<base>` from the repository rather than assuming `main`, and
confirm the new plan change's parent before editing. If an unrelated working-copy change exists,
leave it as a separate head. When resuming a task that already has a plan PR, skip this initialization
and continue its existing bookmark and change stack.

Reuse the **same** bookmark while iterating on one review thread. Give each change an independently
explainable, reviewable, and revertible intent; keep tests and the behavior they prove together,
and do not split by plan step or file type. Before each code-bearing batch push, run the review gate
once over the net diff from the task's previous submitted state to the new stack tip. If a push
safety check fails, `jj git fetch` first, then push again.

Before an implementation or fix change's first push, reshape it in place as needed. After it has
appeared in the PR, keep review feedback out of submitted changes: whether it arrives through
GitHub or the conversation, create `fix(<scope>): ...` children, group tightly coupled requests by
functional concern, and split only requests with independent review or rollback value. A
self-discovered, CI, test, or other non-review correction may edit its owning submitted change when
it remains within the original intent; revalidate affected descendants and review the resulting
net update as one submission batch before pushing. Any genuinely new independent intent still gets
a child change. The plan change is governed separately by the Phase 3 approval loop.

## When to route through the review gate

This skill bundles its own advisory Codex **code** review gate. It applies to pushes that carry
code and not to design-doc pushes:

| Push | Gate? | How to set the bookmark |
| --- | --- | --- |
| Plan draft (Phase 2) and plan revisions (Phase 3) — docs only | **No** | `jj bookmark set <bookmark> -r @` directly |
| Implementation or later fix batch containing code (Phases 4–5) | **Yes** | one gate invocation for the complete bookmark update |
| Merge / post-merge re-sync (Phase 6) | **No** | no bookmark mutation on code |

For a batch containing code, don't run `jj bookmark set` yourself. Run
`scripts/review-and-bookmark.sh <bookmark> [target]` once. It resolves the baseline from the last
fetched remote bookmark state, reviews the complete net diff to the target, reports advisory
suggestions, and moves the local bookmark to the exact reviewed target after any valid result.
Then push once. The gate's full operation — baseline fallback, escalated sandbox permissions,
timeout, the suggestions-driven rework cap, and its fail-closed semantics — is documented in
`references/review-gate.md`.
