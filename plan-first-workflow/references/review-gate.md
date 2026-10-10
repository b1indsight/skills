# Review within the plan-first workflow

Use the standalone [jj-review-gate skill](../../jj-review-gate/SKILL.md) for every
code-bearing bookmark push: implementation in Phase 4 and later code fixes in Phase 5.
Read its entrypoint and [execution procedure](../../jj-review-gate/references/review.md)
before running the gate. It owns the review criteria, result handling, execution permissions,
timeout, and findings-driven rework rules.

Docs-only pushes, including the initial plan and its revisions, skip the gate; see
[the routing table](jj-mechanics.md). Keep the same bookmark and PR throughout the feature.
After the gate passes, the workflow sets the bookmark to the returned commit ID and pushes it
to update the existing PR. A critical result or execution failure stops both operations.

For projects linking this workflow from the shared skills repository, the workflow command
path forwards to the sibling `jj-review-gate` implementation:

```bash
.agents/skills/plan-first-workflow/scripts/review.sh [revision]
```

The sibling `jj-review-gate/` directory must be present alongside `plan-first-workflow/` in
the source repository. To discover and invoke the review skill independently in a project,
also link `jj-review-gate` into that project's `.agents/skills/`.

The review script does not change bookmarks. Capture its stdout on a successful run, then use
that exact commit ID for the bookmark update. See [the command sequence](jj-mechanics.md).
