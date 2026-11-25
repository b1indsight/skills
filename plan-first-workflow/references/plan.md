# Phase 1: Prepare the first draft PR commit

Fetch the latest base with `jj git fetch --remote origin` and confirm it with `jj log`. Read project guidance for checks and documentation locations. Read the affected modules, their callers, the current architecture and feature flows, and any existing plan for this feature.

Put the following together in **the first commit** on the feature bookmark:

1. **Plan.** Extend the existing feature record in place, or start from the [template](../assets/feature-record-template.md). Follow the [document rules](feature-record.md) for architecture changes, cross-module contracts and demos, and rejected alternatives. Link the affected end-to-end flow; if it is new, describe the proposed trigger, steps and observable result so a reviewer can try it.
2. **One executable acceptance test.** Add one new test case that demonstrates the whole change, from its trigger through the affected modules to the observable result. Assert what distinguishes the requested change from the baseline, not calls to private helpers. For an algorithm-only change, exercise the existing interface with an input or measurable criterion that exposes the intended difference. Do not skip the test or implement behavior to turn it green before approval.
3. **Definitions in source, when the contract changes.** Add or update just the cross-module method signatures and field definitions used by the demo and test. Use explicit unimplemented stubs where a body is required (e.g., Rust `todo!()` or Python `raise NotImplementedError`). Preserve existing behavior on unaffected paths. Do not scaffold private helpers. For an algorithm update with no cross-module interface change, omit this part entirely.

**First-commit invariant:** Before pushing, build the entire repository and run the full test suite. The build must succeed and all existing tests must pass. The new acceptance test must be the only failure: it must reach the changed path and fail at its stub or at an assertion exposing the missing behavior. A compilation, setup, or unrelated test failure does not qualify. If the invariant is unmet, do not push. Report the commands, results, and exact failure point in the draft PR.

Describe this first planning commit and push it directly on the named bookmark, without running the automated code review gate. Open one **draft** PR with the test result; an expected failure is not merge-ready. Wait for [explicit approval](approval-gate.md) before implementing behavior. Use the [routing table](jj-mechanics.md) for subsequent pushes.
