# Project documents and the feature record

Maintain two long-lived documentation directories in the target project. Use its existing equivalents when present; otherwise use `docs/architecture/` and `docs/feature-walkthroughs/`.

- **Architecture** describes the system down to modules: their responsibilities, dependencies, and the data or control that crosses their boundaries. Stop at the module boundary. Update the affected pages when this map changes.
- **Feature walkthroughs** guide a reviewer through a feature from trigger to observable result. State the starting conditions, who or what triggers the flow, the steps to follow, and what counts as success. Include failure or retry outcomes when they change what the user sees. Link the demo-derived behavior test and update the walkthrough when the flow changes.

During planning, link existing pages and describe proposed changes in the feature record. During implementation, update the affected pages alongside the code. If either directory is missing, start it with just the modules or walkthrough needed for the feature being implemented; leave unrelated parts of the repository undocumented until work touches them.

These directories describe the project across PRs. The feature record describes one proposed change. Extend an existing plan at its original path and preserve its initial text; add only the missing sections needed to review this work, and do not invent earlier history. Otherwise use the project's convention or `docs/feature-record/<slug>.md`. Link the affected project pages rather than copying the module map or maintaining a second signature list.

Use the [template](../assets/feature-record-template.md) for the initial plan and each substantive amendment: acceptance demo and expected result; cross-module interface and behavior, including any architecture delta; rejected alternatives and reasons. Keep the demo separate from the interface sketch. In the timeline, include only the subjects affected by the amendment. Do not invent a contract or a rejected option. Keep private algorithms, helper inventories, and per-file implementation steps out of both sections.

The plan adapts the [Rust RFC outline](https://github.com/rust-lang/rfcs/blob/master/0000-template.md) for proposal review; timeline entries follow [architecture decision records (ADRs)](https://learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record) to preserve a decision and its rationale when later decisions supersede it.

Keep the shared initial plan as the baseline. Start with an empty timeline; append substantive changes oldest first, distinguishing proposed amendments from approved ones. Link the earlier decision when superseding it. Do not log approvals alone, commits, tool runs, or routine implementation progress. Keep test commands, results, and remaining validation limits with the PR evidence. Do not record volatile project statistics such as test counts or coverage figures; they go stale and force updates only to stay current.
