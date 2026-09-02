---
name: codex-tool-constraints
description: Mandatory constraints for Codex tool usage. Use for every task that reads files or otherwise invokes tools, so tool calls stay focused and avoid loading unnecessary data.
---

# Codex Tool Constraints

Apply these constraints before invoking tools and throughout the task.

## File Reading

1. Limit an ordinary file-read call to at most 80 lines. When the relevant location is already known, read only that range and include the smallest useful amount of surrounding context.
2. Before reading a large file, search for relevant filenames, symbols, or text to locate the likely range. Then read the matching region in chunks of no more than 80 lines.
3. Do not work around the limit by reading an entire large file as consecutive 80-line chunks. Refine the search or inspect only additional ranges justified by the task.
4. A whole-file read is acceptable when the file is known to contain no more than 80 lines. If its size is unknown, check its line count or begin with a targeted search instead of dumping the file.
