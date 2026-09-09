---
name: codex-tool-constraints
description: Mandatory constraints for Codex tool usage. Use for every task that reads or writes files or otherwise invokes tools; covers focused file reads and local edit caches organized by date.
---

# Codex Tool Constraints

Apply these constraints before invoking tools and throughout the task.

## File Reading

1. Limit an ordinary file-read call to at most 80 lines. When the relevant location is already known, read only that range and include the smallest useful amount of surrounding context.
2. Before reading a large file, search for relevant filenames, symbols, or text to locate the likely range. Then read the matching region in chunks of no more than 80 lines.
3. Do not work around the limit by reading an entire large file as consecutive 80-line chunks. Refine the search or inspect only additional ranges justified by the task.
4. A whole-file read is acceptable when the file is known to contain no more than 80 lines. If its size is unknown, check its line count or begin with a targeted search instead of dumping the file.

## File Writing

1. Edit target files directly when possible. When file modifications need scratch files, such as drafts, intermediate copies, patches, or helper scripts, store them in `<project-root>/.cache/<session-start-date>/`. Do not use `/tmp`, `/var/tmp`, `$TMPDIR`, or a project `tmp/` directory for these artifacts. Outside a project, use the session's starting working directory as the root.
2. Name `<session-start-date>` from the session's local startup date in `YYYY-MM-DD` format. Reuse that date directory throughout the session, including later turns and across midnight. Use the supplied session start time when available; otherwise capture the local date when first applying this skill and keep it fixed. Sessions started on the same day share the date directory; use distinct filenames to avoid overwriting another session's artifacts.
3. Keep cache artifacts out of version control.
