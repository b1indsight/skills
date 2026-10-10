# Skills 目录

本仓库收录的全局可复用 skill 索引。**本文件由 `scripts/gen-skills-index.sh` 自动生成，请勿手工编辑。**

| Skill | 说明 |
| --- | --- |
| [`code-principles`](code-principles/) | Mandatory code principles for any task that updates code. Use this skill without exception for implementation, fixes, refactoring, test changes, and every other code update. |
| [`codex-tool-constraints`](codex-tool-constraints/) | Mandatory constraints for Codex tool usage. Use for every task that reads or writes files or otherwise invokes tools; covers focused file reads and local edit caches organized by date. |
| [`conversation-style`](conversation-style/) | Apply user-defined wording preferences and restrictions to assistant replies and conversational writing. Use when composing replies under these rules or when the user asks to control particular phrases, sentence patterns, or tones. |
| [`jj-bookmark-review`](jj-bookmark-review/) | Gate Jujutsu bookmark changes on an independent Codex code review after code generation or modification. Use before creating, setting, moving, or advancing a bookmark; critical findings block the operation. |
| [`plan-first-workflow`](plan-first-workflow/) | Plan and deliver a feature or non-trivial repository change through explicit plan approval and implementation on one bookmark and PR. Use when the project follows the plan-first workflow; route small changes through its lightweight path. |
| [`technical-article-visuals`](technical-article-visuals/) | Create or edit statistical charts, flowcharts, architecture diagrams, structural diagrams, and supporting conceptual icons for technical articles. Load the relevant drawing module and apply shared communication principles, visual specifications, workflow, and acceptance criteria. |
