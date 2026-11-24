# AGENTS.md

面向 agent（以及维护者）的操作指南。本仓库是**全局可复用 skill 的唯一真源**：各项目只通过软链接引用这里的 skill，不复制其内容。

## 仓库约定

- 每个 skill 占一个顶层目录 `<skill-name>/`，其中至少包含一个 `SKILL.md`（带 `name` / `description` frontmatter）。
- `SKILLS.md` 是自动生成的目录索引，**不要手工编辑**，改动源头后用脚本重建。
- `scripts/` 存放仓库维护脚本。
- `scripts/skill-dependencies.txt` 记录实际跨 skill 依赖，每行 `owner dependency`，名称对应真源目录；新增或移除依赖时同步更新。

## 维护流程

### 新增一个 skill

1. 新建目录 `<skill-name>/` 并编写 `SKILL.md`（frontmatter 至少含 `name`、`description`）。
2. 若 skill 带脚本，确认其可执行位：`chmod +x <skill-name>/scripts/*.sh`。
3. 若使用其他 skill 的文件或脚本，更新 `scripts/skill-dependencies.txt`。
4. 刷新目录索引：`./scripts/gen-skills-index.sh`。
5. 提交并推送：`git add -A && git commit && git push`。
6. 在需要用到它的项目里用安装脚本建立软链接（见下）。

### 修改已有 skill

- 直接改对应目录下的文件即可；由于各项目是软链接引用，改动会实时生效。
- 若改动了 `name` 或 `description`，运行 `./scripts/gen-skills-index.sh` 重建索引。
- 若新增或移除了实际跨 skill 依赖，同步更新 `scripts/skill-dependencies.txt`。
- 提交并推送。

### 从其他项目迁移 skill 进来

1. 把真实目录 `mv` 进本仓库：`mv <project>/.../<skill-name> ./<skill-name>`。
2. 在原位置建软链接指回本仓库：`ln -s "$PWD/<skill-name>" <project>/.../<skill-name>`。
3. 验证软链接可读：`cat <project>/.../<skill-name>/SKILL.md | head`。
4. 刷新索引、提交、推送。
5. 注意：若该 skill 在原项目里本就被 gitignore，原项目侧无需改动；否则需在原项目提交“目录 → 软链接”的变更。

### 在项目中引用 skill（软链接）

```bash
# 在本仓库运行，可一次指定多个 skill：
./scripts/skills.sh install "/path/to/project" plan-first-workflow code-principles
# 只读检查已安装的本仓库 skill 和所有断链：
./scripts/skills.sh doctor "/path/to/project"
# 显式指定时，缺失的安装也会报错：
./scripts/skills.sh doctor "/path/to/project" plan-first-workflow
```

- 安装到目标项目的 `.agents/skills/`，链接使用本仓库绝对路径。
- 同源链接重复安装不变，指定 skill 的断链自动修复；真实文件、真实目录以及其他来源的有效链接报错并保留。多项安装先完成全部预检，再写入。
- 项目根路径可以是软链接；`.agents` 或 `.agents/skills` 自身是软链接时拒绝操作，避免写到项目外。
- `doctor` 不写文件；无 skill 参数时仅忽略本仓库没有同名目录的健康外部 skill。本仓库已有同名目录但项目链接指向其他有效来源时仍会报错，不要求安装本仓库全部 skill。
- 安装和诊断依据依赖清单检查真源依赖的 `SKILL.md` 是否可读，不自动给项目增加依赖链接。当前 `plan-first-workflow` 依赖 `jj-review-gate`。

## 注意事项

- 软链接指向本仓库的**绝对路径**，请勿随意移动本仓库位置；如确需移动，须同步更新各项目中的软链接。
- 只在本仓库维护 skill 的唯一真源，各项目一律通过软链接引用，避免出现多份副本各自漂移。
- 每次改动 skill 结构后，务必重新生成 `SKILLS.md` 再提交，保持索引与实际目录一致。
