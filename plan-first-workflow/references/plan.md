# Phase 1: Prepare the first draft PR commit

Fetch the latest base with `jj git fetch --remote origin` and confirm it with `jj log`. Read project guidance, the affected modules and callers, the current architecture and feature flows, and any existing plan for this feature.

The base branch and the build, test, lint, and packaging commands are project facts, not workflow facts. Take them from the project's `AGENTS.md` / `CLAUDE.md` or CI config; if they are not recorded, ask the user or infer them from the repo rather than assuming. Name the feature bookmark `feat/<slug>`, `fix/<slug>`, or `docs/<slug>`.

The first commit contains only the feature record. Extend it in place or use the [template](../assets/feature-record-template.md). Follow the [document rules](feature-record.md) for architecture changes, cross-module contracts, and rejected alternatives.

Put demo code **in the plan**: show how a caller triggers the proposed behavior and what result to expect. For an algorithm change, use the existing interface and choose an input that distinguishes the new behavior. If a module boundary changes, sketch the proposed signatures and fields beside the demo. The demo is a proposal, not an executed test or validation result.

Check the diff contains only the plan. No executable test, production edit, repository build, or test run is required to publish this documentation-only commit. Use the [draft publication commands](jj-mechanics.md), then stop at the [approval gate](approval-gate.md).
