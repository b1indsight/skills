# [Feature name] — Feature flow

**Stage:** Planning
**PR:** [Link when available]

<!-- Fill the initial plan before seeking approval. Keep detail proportional to
the feature; briefly explain inapplicable sections and omit unused optional fields.
When adopting an existing plan, retain its original text instead of rewriting it
to fit this outline, then append the timeline. Do not invent earlier history. -->

## 1. Initial plan

### Summary and motivation

[Brief proposal, the problem it solves, who is affected, and why the change is
needed. Describe the current behavior and a concrete motivating use case.]

### Goals, scope, and success criteria

[Intended outcomes, observable acceptance criteria, scope boundaries, explicit
non-goals, and constraints that shape the design.]

### Proposed behavior

[Explain the intended user or developer experience with a before/after example.
Describe relevant error cases and compatibility changes. This is proposed behavior,
not a claim that the feature has already been implemented.]

### Technical design and affected modules

[Responsibilities, interfaces, data or control flow, and important edge cases.
Describe interactions with existing features at the detail needed for review.]

- `[path or module]`: [Responsibility and intended change]

### Alternatives and rationale

[Compare the chosen approach with credible alternatives, including a simpler
approach or leaving behavior unchanged. Explain the trade-offs and why this choice
fits the requirements. Link relevant prior work and lessons when useful.]

### Costs, risks, and mitigations

[Downsides of the chosen approach, added complexity, and relevant compatibility,
operational, or maintenance costs. Explain mitigations and accepted limitations.]

### Implementation order

1. [First step and dependency, if any]
2. [Next step]

[Include migration, rollout, or rollback steps only where the change needs them.]

### Validation and ablation strategy

- **Tests:** [Behaviors to prove, important failure cases, and relevant checks]
- **Ablation:** [Material mechanisms to remove or simplify in comparisons;
  representative inputs, comparable conditions, and acceptance criteria]
- **Timing:** Run ablation after implementation and before automated code review;
  rerun affected checks after simplification.
- **Applicability:** [If no material complexity is added, explain why ablation
  does not apply instead of inventing an experiment.]

### Open questions and deferred work

[Separate questions that must be resolved before approval from those that can be
resolved during implementation. State how or when to resolve them. Keep possible
future extensions outside this PR's committed scope.]

## 2. PR change timeline

<!-- Append entries in chronological order for meaningful requirement changes,
implementation updates, and design decisions across this PR. Preserve the
initial plan and prior entries; record later corrections in a new entry.
Do not add an entry for every commit or tool run, or copy the conversation log.
Start with no entries; append only events that have actually occurred.

Repeat the scaffold below. Keep sequence numbers stable and increasing.
Include an event date only when known; otherwise omit it or mark it unknown.
For material design decisions, fill context, options, decision/status, and
consequences. Routine updates need only trigger, actual changes, evidence, and
outcome as relevant; do not invent alternatives or require a separate ADR file.
Append later decision/status changes with links to earlier entries; do not rewrite
the original record. The latest applicable entry determines the current decision.
Decision acceptance and implementation progress are separate. A status label is
not approval; cite the actual approval when recording it.

### [001] — [Known date, if available] — [Change summary]

- **Context / requirement update:** [Trigger, changed requirements, constraints,
  and decision drivers. Identify the requester or discussion when relevant.]
- **Options considered:** [Credible alternatives and their relevant trade-offs;
  link earlier analysis if it still applies.]
- **Decision / status:** [Choice and reasons; proposed, accepted, rejected, or
  superseded as of this entry. Identify the approval source when applicable.]
- **Consequences:** [Expected benefits, costs, risks, and follow-up obligations;
  distinguish expectations from observed results.]
- **Related records:** [Link an earlier entry being followed up or the decision
  being superseded; explain which part changes. Omit when none applies.]
- **Implemented changes:** [What was actually completed, affected files or
  modules, and deviations from the initial plan. Say if no code changed.]
- **Evidence / validation:** [Checks actually run and their results; for
  ablation, setup, reproducible commands, comparisons, and resulting decisions.
  Distinguish proposed checks from executed checks and record limitations.]
- **Outcome / pending:** [Resulting behavior and status, unresolved questions,
  deferred work, or next steps. Link PR discussion or commits when useful.]
-->
