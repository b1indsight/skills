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

1. Prefer clear names, types, and structure to express intent, and comment only on information the code cannot express directly.
2. Add docstrings to complex functions, types, interfaces, and non-obvious public APIs.
3. When relevant, use docstrings to explain purpose, parameters, return values, errors, side effects, ownership, and concurrency requirements.
4. Use implementation comments to explain design rationale, invariants, and non-obvious boundaries rather than restating the code.
5. Document key constraints in concurrency, state machines, resource cleanup, retries and timeouts, platform differences, and unsafe code.
6. Make each TODO or FIXME identify a concrete issue and, when possible, link an issue or state its removal condition.
7. Update or remove affected comments whenever behavior, names, or policy values change.
8. Before finishing, verify comments match the final implementation and contain no stale names, values, or behavior descriptions.

## Abstraction and Duplication

1. Avoid over-abstraction, but don't let duplication spread silently. For a small, local second copy, leave a note linking the two sites instead of abstracting on sight, and extract only once they must change in lockstep, drift, or recur a third time. Keep by-design duplication separate, never merge merely coincidental similarity, and never duplicate large or load-bearing logic. Prefer duplication over the wrong abstraction.
2. Add a layer of indirection only when it hides a real variation or decision behind a stable boundary and thereby reduces overall complexity; a layer that only forwards calls is not worth it.
3. Add a parameter, flag, or option only when a caller actually varies it; a knob every caller sets to the same value is dead complexity. Hard-code the value now and introduce the knob when a second, real setting appears.

## Scope and Consistency

1. Make the smallest change that solves the problem. Don't refactor unrelated code, add speculative flexibility (YAGNI), or widen scope beyond the task.
2. Match the surrounding code's conventions, naming, and idioms instead of introducing your own.

## Error Handling

1. Validate inputs at trust boundaries, and handle each error where you can actually act on it — never swallow errors silently or catch broadly without handling them.
2. Fail fast on programmer errors; degrade gracefully on expected operational failures.

## Completion Check

Before finishing, review the final diff against the principles above and confirm the test scope stays proportional to the change's risk and complexity.
