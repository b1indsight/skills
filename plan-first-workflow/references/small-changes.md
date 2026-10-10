# Small changes

There are two separate reviews here — the human **plan approval** (Phase 3) and the automated
**code review gate** ([review-gate.md](review-gate.md)) — and small changes treat them differently.

Trivial and very small changes skip the *planning ceremony*: no plan doc, no draft PR, no
plan-approval gate. A one-line fix has no design to approve. Commit directly and open a normal
(non-draft) PR.

They do **not** automatically skip the code review gate, because that gate keys off whether a
push carries code, not whether the change was planned:

- A small **code** change (a one-line fix, a small tweak) is still a code-bearing push, so run
  the shared `jj-review-gate` skill before setting and pushing its bookmark — it blocks only confirmed critical findings,
  and a one-liner can still be wrong.
- A **non-code** change (a typo, a comment, a doc tweak) has no code to review, so it skips the
  gate too, like any docs-only push.

Reserve this for changes that are genuinely small; if something starts small but turns into real
feature work, fold it back into the full workflow.
