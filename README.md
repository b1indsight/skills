# skills

全局可复用的 skills 集合。

这个仓库集中保存所有可以被**全局复用**的 skill。任何需要用到某个 skill 的项目，通过**软链接（symlink）**把这里对应的 skill 目录链接到该项目下，从而复用同一份定义，避免重复维护。

已收录的 skill 见 [SKILLS.md](SKILLS.md)（由脚本自动生成的目录索引）。

## 目录结构

```
skills/
├── README.md
├── scripts/            # 索引生成、项目安装和诊断
└── <skill-name>/
    └── SKILL.md        # 单个 skill 的定义
```

每个 skill 占一个子目录，目录内至少包含一个 `SKILL.md`。

## 在其他项目中使用

在本仓库运行安装脚本，将指定 skill 链接到目标项目的 `.agents/skills/` 下。

```bash
./scripts/skills.sh install "/path/to/project" plan-first-workflow
# 一次安装多个 skill：
./scripts/skills.sh install "/path/to/project" code-principles jj-review-gate
```

安装脚本使用本仓库的绝对路径。重复安装会保留已有的同源链接，并修复指定 skill
的断链；遇到真实文件、真实目录或指向其他来源的有效链接时，会报错并保留原内容。
一次安装多个 skill 时，脚本先检查所有待安装项再写入，预检失败不会安装其中一部分。
目标项目根路径可以是软链接；项目内的 `.agents` 和 `.agents/skills` 自身不能是软链接，
以免安装位置跳出目标项目。

链接后，对本仓库中该 skill 的任何修改都会自动在所有引用它的项目中生效。

## 检查项目链接与依赖

`doctor` 只检查，不修改文件：

```bash
# 检查已安装的本仓库 skill，以及安装目录中的所有断链：
./scripts/skills.sh doctor "/path/to/project"
# 确认指定 skill 已安装，并检查其链接和依赖：
./scripts/skills.sh doctor "/path/to/project" plan-first-workflow jj-review-gate
```

不指定 skill 时，仅忽略本仓库没有同名目录的健康外部 skill；本仓库已有同名目录，
但项目链接指向其他有效来源时仍会报错。不会要求项目安装本仓库的所有 skill。
显式指定 skill 后，未安装的 skill 会被报告为缺失。

跨 skill 依赖记录在 [`scripts/skill-dependencies.txt`](scripts/skill-dependencies.txt)，
每行格式为 `owner dependency`，名称对应本仓库的 skill 目录。安装和诊断时，脚本
检查依赖目录的 `SKILL.md` 是否可读；依赖从本仓库同级目录读取，脚本不会自动
为项目增加依赖链接。目前 `plan-first-workflow` 依赖 `jj-review-gate`。

## 项目工作流与独立审查

`plan-first-workflow` 负责规划、审批、实现和 PR 收尾，其审查阶段调用独立的
[`jj-review-gate`](jj-review-gate/SKILL.md)。审查规则、脚本和 schema 只在后者维护。
两个目录保持同级；工作流的 `scripts/review.sh [revision]` 转发到共享实现。
审查脚本只返回结果和审查通过的 commit ID；设置 bookmark 和推送由工作流负责。
原 `review-and-bookmark.sh <bookmark> [revision]` 已移除，手工调用应改用新接口。

`jj-review-gate` 替代原来的 `jj-bookmark-review`，也可以单独链接到项目的
`.agents/skills/` 使用，无需规划文档或 PR。原先引用 `jj-bookmark-review` 的项目应
将 skill 软链接和指令中的名称更新为 `jj-review-gate`。

### `plan-first-workflow` 的功能记录怎么产生？

对于需要规划的功能，agent 在目标项目核对远端基线、项目约定和已有方案。已有计划或设计文档时，在原路径保留原文并补充缺失信息；没有时，复制 [Markdown 模板](plan-first-workflow/assets/feature-record-template.md)，按项目事实填写。新文件优先遵循项目的命名和目录约定，没有约定时使用 `docs/feature-record/<slug>.md`。首次只提交文档，以草稿 PR 征求评审；用户明确批准后，才在同一 bookmark、同一 PR 上写测试和实现。见[规划步骤](plan-first-workflow/references/plan.md)和[审批规则](plan-first-workflow/references/approval-gate.md)。[很小的改动](plan-first-workflow/references/small-changes.md)可以跳过计划文档和草稿 PR。

| 文档部分 | 写什么、何时写 |
| --- | --- |
| 初始方案（送审前） | 写清动机、目标与范围、成功标准，用例说明预期行为，再列技术设计与受影响模块、备选方案和取舍、成本与风险、实施顺序、验证策略。区分审批前必须回答的问题、实现时可解决的问题和延期事项。若增加了复杂机制，先设计与简化版本的对照；不适用时说明原因。 |
| PR 变更时间线（有事才追加） | 初始为空。方案分享后保留原文，按发生顺序记录实质性需求修订、实现偏差和设计决策。重大决策写明背景、选项、决定及后果；后续决定取代旧决定时链接旧条目。区分提议、已批准、已实现与延期，不为单纯批准、阶段切换或每次提交另记一条。 |

[实现阶段](plan-first-workflow/references/implement.md)在自动代码审查前把实际对照条件、可复现命令、结果和据此做出的取舍写回时间线；无法验证时注明限制。[标记 PR 可评审前](plan-first-workflow/references/finish.md)补齐最终验证和剩余限制。阅读时，以初始方案和后来**已批准**的修订确定范围，以时间线中的实现记录和验证证据判断完成情况。详见[功能记录规则](plan-first-workflow/references/feature-record.md)。

## 新增 skill

1. 在本仓库新建一个 `<skill-name>/` 目录并编写 `SKILL.md`。
2. 若实际使用其他 skill 的文件或脚本，在 `scripts/skill-dependencies.txt` 中登记依赖。
3. 运行 `./scripts/gen-skills-index.sh` 刷新目录索引 [SKILLS.md](SKILLS.md)。
4. 提交并推送到远端。
5. 在需要用到它的项目里运行 `./scripts/skills.sh install "/path/to/project" <skill-name>`。

## 说明

- 软链接指向的是本仓库的路径，请勿随意移动本仓库位置；如需移动，需同步更新各项目中的软链接。
- 建议只在本仓库中维护 skill 的“唯一真源”，各项目仅通过软链接引用。
