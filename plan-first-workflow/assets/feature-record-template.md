# [Feature name] — Feature record

**Stage:** Planning
**PR:** [Link when available]

<!-- Fill the initial plan before seeking approval. Keep detail proportional to
the feature; briefly explain inapplicable sections and omit unused optional fields.
When adopting an existing plan, retain its original text instead of rewriting it
to fit this outline, then append the timeline. Do not invent earlier history. -->

## 1. Initial plan

### Summary and motivation

- **Problem and current behavior:** [Describe the problem, what happens today,
  and a concrete motivating use case.]
- **Affected users and motivation:** [Explain who is affected and why the change
  is needed from their perspective.]
- **Proposal summary:** [Briefly describe the proposed change and how it addresses
  the motivating use case.]

### Goals, scope, and success criteria

- **Goals and success criteria:** [State the intended outcomes and observable
  acceptance criteria that determine whether the change succeeds.]
- **Scope and non-goals:** [Define what this change includes, its boundaries,
  and what it explicitly does not attempt to solve.]
- **Constraints:** [Identify the project constraints that shape the design and
  limit the available approaches.]

### Proposed behavior

- **Before/after experience:** [Explain the intended user or developer experience
  with a concrete example of current and proposed behavior.]
- **Error cases:** [Describe relevant failure cases and the behavior users or
  callers should observe in each case.]
- **Compatibility:** [Describe proposed compatibility changes and their effects
  on existing users or callers. These are proposals, not claims of implementation.]

### Technical design and affected modules

- **Affected modules and responsibilities:** [Identify where the change belongs
  and how responsibilities are divided. Explain the responsibility of every type
  to be added. For each new core concept, specify its representing type field by
  field, including every field's name, type, and meaning.]
  - `[path or module]`: [Responsibility and intended change]
- **Interfaces and flow:** [Describe interfaces, data or control flow, and
  interactions with existing features at the detail needed for review. Provide
  the exact signature and purpose of every planned method.]
- **Edge cases:** [Explain important boundary conditions and how the design
  handles them across the affected modules.]

### Alternatives and rationale

- **Options:** [Compare the chosen approach with credible alternatives, including
  a simpler approach or leaving behavior unchanged.]
- **Trade-offs and choice:** [Explain the relevant trade-offs, why the chosen
  approach fits the requirements, and why the alternatives were not selected.]
- **Prior work:** [When useful, link relevant prior work and explain which lessons
  inform this choice.]

### Costs, risks, and mitigations

- **Costs and downsides:** [Describe added complexity and relevant compatibility,
  operational, or maintenance costs of the chosen approach.]
- **Risks and limitations:** [Identify what could go wrong, its likely impact,
  and the limitations being accepted.]
- **Mitigations:** [Explain how the identified risks will be reduced and which
  risks or limitations remain after those mitigations.]

### Implementation order

- **Steps and dependencies:** [List the implementation steps in execution order,
  explaining dependencies where they affect that order.]
  1. [First step and dependency, if any]
  2. [Next step]
- **Migration, rollout, and rollback:** [Include these steps only where the change
  needs them, and indicate where they fit into the implementation sequence.]

### Validation and ablation strategy

- **Tests:** [Describe the behaviors to prove, important failure cases, and
  relevant checks that demonstrate the acceptance criteria.]
- **Ablation:** [Material mechanisms to remove or simplify in comparisons;
  representative inputs, comparable conditions, and acceptance criteria. If no
  material complexity is added, explain why ablation does not apply instead of
  inventing an experiment.]
- **Timing:** Run ablation after implementation and before automated code review;
  rerun affected checks after simplification.

### Open questions and deferred work

- **Approval blockers:** [List questions that must be resolved before approval,
  why they block it, and how or when they will be resolved.]
- **Implementation questions:** [List questions that can be resolved during
  implementation, with how or when they will be addressed.]
- **Deferred work:** [Identify deferred work and possible future extensions,
  keeping them outside this PR's committed scope.]

## 2. PR change timeline

<!-- Append entries in chronological order for meaningful requirement changes,
implementation updates, and design decisions across this PR. Preserve the
initial plan and prior entries; record later corrections in a new entry.
Do not add an entry for every commit or tool run, or copy the conversation log.
Omit standalone plan approvals, permission to start implementation, phase transitions,
and status-only updates. If approval includes substantive amendments, record those amendments.
Start with no entries; append only events that have actually occurred.

Repeat the scaffold below. Keep sequence numbers stable and increasing.
Include an event date only when known; otherwise omit it or mark it unknown.
For material design decisions, fill context, options, decision/status, and
consequences. Routine updates need only trigger, actual changes, evidence, and
outcome as relevant; do not invent alternatives or require a separate ADR file.
Append later decisions that change the substantive approach with links to earlier entries; do not rewrite
the original record. Apply the initial plan together with later approved amendments.
A new entry or proposal does not itself authorize implementation.
Decision acceptance and implementation progress are separate. A status label is
not approval; cite the actual approval when recording it.

### [001] — [Known date, if available] — [Change summary]

- **Context / requirement update:**
  - [Describe the trigger and changed requirements; identify the requester or
    discussion when relevant.]
  - [Explain the constraints and decision drivers that shape this update.]
- **Options considered:**
  - [Describe the credible alternatives considered for this update.]
  - [Explain their relevant trade-offs; link earlier analysis if it still applies.]
- **Decision / status:**
  - [State the choice and the reasons for it.]
  - [Mark its status as proposed, accepted, rejected, or superseded as of this entry.]
  - [Identify the approval source when applicable.]
- **Consequences:**
  - [Describe expected benefits, costs, risks, and follow-up obligations.]
  - [Report observed results separately so expectations are not presented as facts.]
- **Related records:**
  - [Link an earlier entry being followed up or the decision being superseded.]
  - [Explain which part changes. Omit this field when no related record applies.]
- **Implemented changes:**
  - [Describe what was actually completed and the affected files or modules.]
  - [Explain deviations from the initial plan. Say explicitly if no code changed.]
- **Evidence / validation:**
  - [List checks actually run and their results.]
  - [For ablation, include setup, reproducible commands, comparisons, and resulting
    decisions.]
  - [Record limitations and distinguish proposed checks from executed checks.]
- **Outcome / pending:**
  - [Describe the resulting behavior and current status, distinguishing requested,
    approved, implemented, and deferred work.]
  - [List unresolved questions, deferred work, or next steps.]
  - [Link PR discussion or commits when useful.]
-->
