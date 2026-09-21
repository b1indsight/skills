# [Feature name] — Feature flow

**Status:** Planning
**PR:** [Link when available]

<!-- Keep detail proportional to the feature; omit unused optional fields.
When adopting an existing plan, retain its original text instead of rewriting it
to fit this outline, then append the timeline. Do not invent earlier history. -->

## 1. Initial plan

### Context and intended outcome

[Problem, intended behavior, and acceptance criteria. Include scope boundaries,
constraints, and risks only where they affect the approach or its evaluation.]

### Approach and reasons

[Proposed approach, material choices, alternatives considered, and why this
approach fits. Explain relevant costs and tradeoffs.]

### File and module map

- `[path or module]`: [Responsibility and intended change]

### Implementation order

1. [First step and dependency, if any]
2. [Next step]

### Validation and ablation strategy

- **Tests:** [Behaviors to prove, important failure cases, and relevant checks]
- **Ablation:** [Material mechanisms to remove or simplify in comparisons;
  representative inputs, comparable conditions, and acceptance criteria]
- **Timing:** Run ablation after implementation and before automated code review;
  rerun affected checks after simplification.
- **Applicability:** [If no material complexity is added, explain why ablation
  does not apply instead of inventing an experiment.]

## 2. PR change timeline

<!-- Append entries in chronological order for meaningful requirement changes,
implementation updates, and design decisions across this PR. Preserve the
initial plan and prior entries; record later corrections in a new entry.
Do not add an entry for every commit or tool run, or copy the conversation log.
Start with no entries; append only events that have actually occurred.

Repeat the scaffold below. Keep sequence numbers stable and increasing.
Include an event date only when known; otherwise omit it or mark it unknown.
Omit fields that add no useful information.

### [001] — [Known date, if available] — [Change summary]

- **Requirement / trigger:** [What changed, who requested it if relevant, and
  the intended behavior. Clearly mark requests that remain unimplemented.]
- **Implemented changes:** [What was actually completed, affected files or
  modules, and deviations from the initial plan. Say if no code changed.]
- **Design choices:** [Decision, alternatives considered, reasons, and relevant
  tradeoffs; explain added, retained, simplified, or removed mechanisms.]
- **Evidence / validation:** [Checks actually run and their results; for
  ablation, setup, reproducible commands, comparisons, and resulting decisions.
  Distinguish proposed checks from executed checks and record limitations.]
- **Outcome / pending:** [Resulting behavior and status, unresolved questions,
  deferred work, or next steps. Link PR discussion or commits when useful.]
-->
