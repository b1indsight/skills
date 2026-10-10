---
name: jj-bookmark-review
description: Gate Jujutsu bookmark changes on an independent Codex code review after code generation or modification. Use before creating, setting, moving, or advancing a bookmark; critical findings block the operation.
---

# JJ Bookmark Review

Before a bookmark change after code generation or modification, read
[the execution procedure](references/review.md) and use the bundled
`scripts/review-and-bookmark.sh <bookmark> [revision]`. Never run a bookmark-mutating
`jj` command directly when this skill applies.

## Gate rules

- Review execution and structured-result parsing must succeed before the bookmark changes.
- Report every finding. Critical findings block the bookmark and requested push;
  high, medium, and low findings are report-only.
- After a valid result, report it and continue the requested push on a pass, or stop on a
  critical failure. Do not automatically edit files or rerun review in response to findings.
- The execution procedure covers required escalation, timeout, report storage, and supported
  bookmark operations. Read it before the first execution, including any rework review.

## Rework authorization

Review findings never authorize file changes. Findings-driven rework requires a new, explicit
user request after the findings have been reported. One authorization covers only the requested
edits and one subsequent review; findings from that review are again report-only and require
another explicit user request before any further rework.

The original implementation request and instructions such as "finish", "proceed", or "push" do
not authorize findings-driven rework. Do not ask to rework: report the findings, then continue
the requested push after a pass or stop after a critical gate failure.

Normal forward work requested by the user, continued feature development, and fixes unrelated
to prior findings are not findings-driven rework. Review them normally when the bookmark next
moves.
