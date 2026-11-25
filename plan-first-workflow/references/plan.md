# Phase 1: Prepare the first draft PR commit

Fetch the latest base with `jj git fetch --remote origin` and confirm it with `jj log`. Read project guidance for checks and documentation locations. Read the affected modules, their callers, the current architecture and feature flows, and any existing plan for this feature.

Put the following together in **the first commit** on the feature bookmark:

1. **Plan.** Extend the existing feature record in place, or start from the [template](../assets/feature-record-template.md). Follow the [document rules](feature-record.md) for architecture changes, cross-module contracts and demos, and rejected alternatives. Link the affected end-to-end flow; if it is new, describe the proposed trigger, steps and observable result so a reviewer can try it.
   Sketch proposed cross-module signatures and fields in the plan only. If a sketch needs a method body, use an explicit unimplemented stub in its Markdown code block. Leave production interfaces, callers, and implementations unchanged until approval. Omit the sketch for an algorithm change with no interface change.
2. **One executable acceptance test.** Exercise an existing entry point without compile-time references to proposed symbols. Assert the observable result of the new behavior (for example, send the proposed request through the existing HTTP server and check the response). For an algorithm change, choose an input or measurable criterion that distinguishes the new behavior. If no current entry point can express the acceptance scenario, report the blocker rather than introducing a source stub or a test that fails unconditionally.

**First-commit invariant:** Before pushing, build the entire repository and run the full test suite. The build must succeed and all existing tests must pass. The new acceptance test must be the only failure, at the assertion exposing the missing behavior. A compilation, setup, or unrelated test failure does not qualify. If the invariant is unmet, do not push. Report the commands, results, and exact failure point in the draft PR.

Describe this first planning commit and push it directly on the named bookmark, without running the automated code review gate. Open one **draft** PR with the test result; an expected failure is not merge-ready. Wait for [explicit approval](approval-gate.md) before implementing behavior. Use the [routing table](jj-mechanics.md) for subsequent pushes.
