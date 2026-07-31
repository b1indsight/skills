# skills

全局可复用的 skills 集合。

这个仓库集中保存所有可以被**全局复用**的 skill。任何需要用到某个 skill 的项目，通过**软链接（symlink）**把这里对应的 skill 目录链接到该项目下，从而复用同一份定义，避免重复维护。

## 目录结构

```
skills/
├── README.md
└── <skill-name>/
    └── SKILL.md        # 单个 skill 的定义
```

每个 skill 占一个子目录，目录内至少包含一个 `SKILL.md`。

## 在其他项目中使用

在目标项目中，把需要的 skill 软链接到该项目的 skill 目录下（Claude Code 项目通常是 `.claude/skills/`）。

```bash
# 假设本仓库位于 ~/personal_work/skills
# 在目标项目根目录执行：
mkdir -p .claude/skills
ln -s ~/personal_work/skills/<skill-name> .claude/skills/<skill-name>
```

链接后，对本仓库中该 skill 的任何修改都会自动在所有引用它的项目中生效。

## 新增 skill

1. 在本仓库新建一个 `<skill-name>/` 目录并编写 `SKILL.md`。
2. 提交并推送到远端。
3. 在需要用到它的项目里按上面的方式软链接。

## 说明

- 软链接指向的是本仓库的路径，请勿随意移动本仓库位置；如需移动，需同步更新各项目中的软链接。
- 建议只在本仓库中维护 skill 的“唯一真源”，各项目仅通过软链接引用。
