---
name: jj-review-gate
description: Review a Jujutsu commit diff with two parallel Codex subagents for functionality/security and complexity, returning a critical-only gate result. Use before publishing code changes or when a review gate is requested. Docs-only changes skip the gate.
---

# JJ Review Gate

This skill works independently or as the review subskill of `plan-first-workflow`.
Before reviewing code changes, read [the execution procedure](references/review.md) and run
`scripts/review.sh [revision]`. Docs-only changes skip the gate.

## Parallel review

One read-only Codex coordinator launches exactly two child agents before waiting for either:

- **Functionality and security:** correctness, regressions, concurrency, error handling,
  security, developer-workflow breakage, and material test gaps.
- **Complexity:** branching and state complexity, unnecessary indirection, ownership and API
  boundaries, duplication, cohesion, and concrete in-scope simplifications.

Both agents read the same captured commit diff. The coordinator consolidates their findings;
it does not replace either review with its own. Both child reviews must complete.

## Gate rules

- Review execution, both child reviews, and structured-result parsing must succeed for a valid
  gate result. A missing or incomplete child review fails closed.
- Report every finding. Critical findings fail the gate; high, medium, and low findings
  are report-only.
- The gate reviews and reports; it does not set bookmarks, push changes, or modify source files.
- On a pass, stdout contains only the exact reviewed commit ID. On a failure, stdout is empty.
  The caller decides and performs authorized follow-up actions using that ID.
- Do not automatically edit files or rerun review in response to findings. Read the execution
  procedure before the first run, including any rework review.

## Rework authorization

Review findings never authorize file changes. Findings-driven rework requires a new, explicit
user request after the findings have been reported. One authorization covers only the requested
edits and one subsequent review; findings from that review are again report-only and require
another explicit user request before any further rework.

The original implementation request and instructions such as "finish", "proceed", or "push" do
not authorize findings-driven rework. Do not ask to rework: report the findings, then let the caller continue
authorized work after a pass or stop after a critical gate failure.

Normal forward work requested by the user, continued feature development, and fixes unrelated
to prior findings are not findings-driven rework. Review them normally before publication.
