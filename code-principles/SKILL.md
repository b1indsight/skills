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

## Docstrings and Comments

1. Add a docstring to complex functions, methods, classes, and interfaces, and to a module's public API. Explain how to use it, and include an example when the usage is not obvious.
2. Add a comment to explain *why* something is done, or to supply context or detail the code cannot express on its own. Do not restate what the code already makes clear.

## Abstraction and Duplication

1. Avoid over-abstraction, but don't let duplication spread silently. For a small, local second copy, leave a note linking the two sites instead of abstracting on sight, and extract only once they must change in lockstep, drift, or recur a third time. Keep by-design duplication separate, never merge merely coincidental similarity, and never duplicate large or load-bearing logic. Prefer duplication over the wrong abstraction.
2. Add a layer of indirection only when it hides a real variation or decision behind a stable boundary and thereby reduces overall complexity; a layer that only forwards calls is not worth it.

## Scope and Consistency

1. Make the smallest change that solves the problem. Don't refactor unrelated code, add speculative flexibility (YAGNI), or widen scope beyond the task.
2. Match the surrounding code's conventions, naming, and idioms instead of introducing your own.

## Error Handling

1. Validate inputs at trust boundaries, and handle each error where you can actually act on it — never swallow errors silently or catch broadly without handling them.
2. Fail fast on programmer errors; degrade gracefully on expected operational failures.

## Completion Check

Before finishing, review the final diff against the principles above and confirm the test scope stays proportional to the change's risk and complexity.
