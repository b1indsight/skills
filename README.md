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

## 新增 skill

1. 在本仓库新建一个 `<skill-name>/` 目录并编写 `SKILL.md`。
2. 若实际使用其他 skill 的文件或脚本，在 `scripts/skill-dependencies.txt` 中登记依赖。
3. 运行 `./scripts/gen-skills-index.sh` 刷新目录索引 [SKILLS.md](SKILLS.md)。
4. 提交并推送到远端。
5. 在需要用到它的项目里运行 `./scripts/skills.sh install "/path/to/project" <skill-name>`。

## 说明

- 软链接指向的是本仓库的路径，请勿随意移动本仓库位置；如需移动，需同步更新各项目中的软链接。
- 建议只在本仓库中维护 skill 的“唯一真源”，各项目仅通过软链接引用。
