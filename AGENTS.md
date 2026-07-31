# AGENTS.md

面向 agent（以及维护者）的操作指南。本仓库是**全局可复用 skill 的唯一真源**：各项目只通过软链接引用这里的 skill，不复制其内容。

## 仓库约定

- 每个 skill 占一个顶层目录 `<skill-name>/`，其中至少包含一个 `SKILL.md`（带 `name` / `description` frontmatter）。
- `SKILLS.md` 是自动生成的目录索引，**不要手工编辑**，改动源头后用脚本重建。
- `scripts/` 存放仓库维护脚本。
- 提交信息末尾附带：`Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`。

## 维护流程

### 新增一个 skill

1. 新建目录 `<skill-name>/` 并编写 `SKILL.md`（frontmatter 至少含 `name`、`description`）。
2. 若 skill 带脚本，确认其可执行位：`chmod +x <skill-name>/scripts/*.sh`。
3. 刷新目录索引：`./scripts/gen-skills-index.sh`。
4. 提交并推送：`git add -A && git commit && git push`。
5. 在需要用到它的项目里建立软链接（见下）。

### 修改已有 skill

- 直接改对应目录下的文件即可；由于各项目是软链接引用，改动会实时生效。
- 若改动了 `name` 或 `description`，运行 `./scripts/gen-skills-index.sh` 重建索引。
- 提交并推送。

### 从其他项目迁移 skill 进来

1. 把真实目录 `mv` 进本仓库：`mv <project>/.../<skill-name> ./<skill-name>`。
2. 在原位置建软链接指回本仓库：`ln -s "$PWD/<skill-name>" <project>/.../<skill-name>`。
3. 验证软链接可读：`cat <project>/.../<skill-name>/SKILL.md | head`。
4. 刷新索引、提交、推送。
5. 注意：若该 skill 在原项目里本就被 gitignore，原项目侧无需改动；否则需在原项目提交“目录 → 软链接”的变更。

### 在项目中引用 skill（软链接）

```bash
# 本仓库位于 ~/personal_work/skills
# 在目标项目根目录执行（各项目统一放在 .agents/skills/）：
mkdir -p .agents/skills
ln -s ~/personal_work/skills/<skill-name> .agents/skills/<skill-name>
```

## 注意事项

- 软链接指向本仓库的**绝对路径**，请勿随意移动本仓库位置；如确需移动，须同步更新各项目中的软链接。
- 只在本仓库维护 skill 的唯一真源，各项目一律通过软链接引用，避免出现多份副本各自漂移。
- 每次改动 skill 结构后，务必重新生成 `SKILLS.md` 再提交，保持索引与实际目录一致。
