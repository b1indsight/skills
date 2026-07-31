---
name: code-principles
description: Mandatory code principles for any task that updates code. Use this skill without exception for implementation, fixes, refactoring, test changes, and every other code update.
---

# Code Principles

Apply these principles before writing or modifying code. Review the final diff against them before finishing the task.

## Testing Principles

1. Add tests only when they protect meaningful behavior or a credible regression risk. Omit tests for very small functions whose behavior is deterministic, straightforward, and unlikely to fail.
2. Keep primary execution-path tests simple. Avoid verifying the same logic repeatedly; prefer one representative test whenever possible.
3. Reduce each regression test to the smallest scenario that proves the regression. Add a comment explaining both the triggering mechanism and the real-world scenario.
4. Keep tests deterministic, fast, and readable. Mock I/O, time and sleeps, network access, synchronization, or similar behavior when using the real dependency would be slow or unreliable.

## Completion Check

Before completing any code update:

- Confirm every test protects a distinct, credible risk.
- Remove duplicate coverage, unnecessary helpers, and unnecessary setup.
- Confirm every regression test uses the smallest reproducer and documents its trigger and scenario.
- Replace slow or unreliable dependencies with focused mocks.
- Keep the overall test scope proportional to the risk and complexity of the change.
