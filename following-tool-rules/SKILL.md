---
name: following-tool-rules
description: Enforces mandatory tool usage rules. Use whenever invoking gh or GitHub CLI to access repositories, issues, pull requests, reviews, workflows, releases, or GitHub APIs. All GitHub CLI operations must use gh-bot, including read-only operations.
---

# Tool Usage Rules

## GitHub CLI

Use `gh-bot` as the entry point for every GitHub CLI operation so commands use the configured bot authentication.

### Mandatory Rules

1. Invoke `gh-bot` instead of `gh`, including commands run through scripts or subprocesses. When given a `gh ...` command to execute, replace the executable with `gh-bot` and preserve the required arguments.
2. Apply this rule to both read-only and write operations, including `api`, `repo`, `issue`, `pr`, `run`, `workflow`, and `release` subcommands.
3. Do not bypass the wrapper by invoking the underlying `gh` binary directly, by absolute path, or through an alias or helper.
4. If `gh-bot` is unavailable or its bot authentication or permissions are insufficient, stop the affected operation and report the blocker. Do not fall back to `gh`, borrow personal tokens, or change the user's GitHub authentication configuration to work around it.
5. This skill selects the CLI only. It does not authorize writes or override repository ownership restrictions, approval requirements, or other safety rules.

### Read-only Examples

```bash
gh-bot api --paginate installation/repositories
gh-bot pr list --repo <owner>/<repo> --state all --limit 10
gh-bot pr view <number> --repo <owner>/<repo>
gh-bot run list --repo <owner>/<repo> --limit 5
```
