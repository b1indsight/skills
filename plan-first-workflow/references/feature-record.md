# Feature-record document

Start from [the outline template](../assets/feature-record-template.md) and fill it with the task's
facts. Extend an existing plan in place, preserving its content and path; for new documents,
follow the project's location and naming conventions, or use `docs/feature-record/<slug>.md`.
The initial plan adapts the [Rust RFC outline](https://github.com/rust-lang/rfcs/blob/master/0000-template.md)
for proposal review. Material decisions in the timeline use [ADR structure](https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record):
context, options, decision/status, and consequences. Routine updates use only relevant fields.

Keep the initial plan as the baseline once shared. Append substantive requirement updates,
implementation changes, and design decisions to the timeline in occurrence order, oldest first.
Record each meaningful change batch, not every commit or tool call. Omit standalone process
events such as plan approval, permission to begin implementation, or phase transitions. If
approval includes substantive amendments, record those amendments instead. Distinguish requested,
approved, implemented, and deferred work; an entry does not itself authorize implementation.
Explain what changed and why, including alternatives, trade-offs, and relevant evidence.
Keep decision status separate from implementation progress. Record later decisions that change
the substantive approach in a new entry linked to the earlier record; preserve its original
rationale. A status-only update does not warrant a timeline entry.
Use known dates and references only; do not invent history when extending an existing plan.
Update the document alongside changes, before their code review. Apply the initial plan with
later approved amendments, and identify which earlier decisions an amendment supersedes.
