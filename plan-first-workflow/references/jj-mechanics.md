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
```

Use the routing table below to publish each change. Open the draft PR after the first planning commit is pushed. Add child changes with `jj new` and reuse the same bookmark and PR. If a push safety check fails, fetch and inspect the remote state before retrying.

## When to route through the review gate

This workflow uses the standalone `jj-review-gate` skill for critical-only blocking Codex
**code** review. Route each push as follows:

| Push | Gate? | How to set the bookmark |
| --- | --- | --- |
| First planning commit (Phase 1): plan and acceptance test only | **No** | `jj bookmark set <bookmark> -r @` directly, then `jj git push --remote origin --bookmark <bookmark>` |
| Draft revisions changing the acceptance test | **Yes** | after a pass, set it to the returned reviewed commit ID |
| Revisions changing only documentation | **No** | `jj bookmark set <bookmark> -r @` directly |
| Implementation (Phase 3) and any later code fix (Phase 4) | **Yes** | after a pass, set it to the returned reviewed commit ID |
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
