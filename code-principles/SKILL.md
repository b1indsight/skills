---
name: code-principles
description: Mandatory code principles for any task that updates code. Use this skill without exception for implementation, fixes, refactoring, test changes, and every other code update.
---

# Code Principles

Apply these principles before writing or modifying code. Review the final diff against them before finishing the task.

## Testing Principles

1. Keep test scope proportional to the change's risk and complexity: invest more where a failure is costly or the logic is complex, and less where it is trivial.
2. Add tests only when they protect meaningful behavior or a credible regression risk. Omit tests for very small functions whose behavior is deterministic, straightforward, and unlikely to fail.
3. Keep happy-path tests simple. Avoid verifying the same logic repeatedly; prefer one representative test whenever possible.
4. Reduce each regression test to the smallest scenario that proves the regression. Add a comment explaining both the triggering mechanism and the real-world scenario.
5. Keep tests deterministic, fast, and readable. Mock I/O, time and sleeps, network access, synchronization, and similar dependencies when the real one would be slow or unreliable.

## Completion Check

Before finishing, review the final diff against the principles above and confirm the test scope stays proportional to the change's risk and complexity.
