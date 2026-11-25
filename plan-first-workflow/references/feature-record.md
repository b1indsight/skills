# Project documents and the feature record

Maintain two long-lived documentation directories in the target project. Use its existing equivalents when present; otherwise use `docs/ARCHITECTURE/` and `docs/功能流程/`.

- **ARCHITECTURE** describes the system down to modules: their responsibilities, dependencies, and the data or control that crosses their boundaries. Stop at the module boundary. Update the affected pages when this map changes.
- **功能流程** describes a complete feature as an acceptance walkthrough: starting conditions, triggering actor or event, operations in order, and observable results. Include failure or retry outcomes when they change what the user sees. A reviewer must be able to follow the steps and tell whether the feature works. Link the executable acceptance test; update the walkthrough when the flow changes.

These directories describe the project across PRs. The feature record describes one proposed change. Extend an existing plan at its original path and preserve its initial text; otherwise use the project's convention or `docs/feature-record/<slug>.md`. Link the affected project pages rather than copying the module map or maintaining a second signature list.

Use the [template](../assets/feature-record-template.md) for the initial plan and for each substantive amendment. Both use the same three subjects: the architecture delta if any, new or changed cross-module interfaces with a caller demo and observable behavior, and alternatives rejected with the reason. Omit inapplicable subjects; do not invent a contract or a rejected option. Keep private algorithms, helper inventories, and per-file implementation steps out of both sections.

Keep the shared initial plan as the baseline. Start with an empty timeline; append substantive changes oldest first, distinguishing proposed amendments from approved ones. Link the earlier decision when superseding it. Do not log approvals alone, commits, tool runs, or routine implementation progress. Keep test commands, results, and remaining validation limits with the PR evidence.
