# Skills 目录

本仓库收录的全局可复用 skill 索引。**本文件由 `scripts/gen-skills-index.sh` 自动生成，请勿手工编辑。**

| Skill | 说明 |
| --- | --- |
| [`code-principles`](code-principles/) | Mandatory code principles for any task that updates code. Use this skill without exception for implementation, fixes, refactoring, test changes, and every other code update. |
| [`codex-tool-constraints`](codex-tool-constraints/) | Mandatory constraints for Codex tool usage. Use for every task that reads or writes files or otherwise invokes tools; covers focused file reads and local edit caches organized by date. |
| [`jj-bookmark-review`](jj-bookmark-review/) | Run an independent Codex code review before creating, setting, moving, or advancing a Jujutsu bookmark; critical findings block the bookmark, while other valid results allow it. Use whenever a task would execute `jj bookmark create`, `jj bookmark set`, `jj bookmark move`, or `jj bookmark advance` after code generation or modification in this repository. |
| [`plan-first-workflow`](plan-first-workflow/) | The plan-first, one-PR feature workflow — write a plan and get explicit user approval on a draft PR before writing any code, then implement test-first on the same bookmark and PR. Use this whenever a task means building, implementing, or adding a feature or any non-trivial change in a repository that follows this workflow, even when the user just says "implement X" or "start on Y" without mentioning a plan. |
