#!/usr/bin/env bash
# 生成 SKILLS.md —— 扫描每个 <skill>/SKILL.md 的 frontmatter(name / description),
# 汇总成一张目录表。新增或修改 skill 后运行本脚本即可刷新索引。
#
# 用法： ./scripts/gen-skills-index.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out="SKILLS.md"

{
  echo "# Skills 目录"
  echo
  echo "本仓库收录的全局可复用 skill 索引。**本文件由 \`scripts/gen-skills-index.sh\` 自动生成，请勿手工编辑。**"
  echo
  echo "| Skill | 说明 |"
  echo "| --- | --- |"

  found=0
  for skill_md in */SKILL.md; do
    [ -e "$skill_md" ] || continue
    found=1
    dir="$(dirname "$skill_md")"

    # 取第一段 frontmatter(两个 --- 之间)里的 name / description
    name="$(awk '/^---$/{c++; next} c==1 && /^name:/{sub(/^name:[[:space:]]*/,""); print; exit}' "$skill_md")"
    desc="$(awk '/^---$/{c++; next} c==1 && /^description:/{sub(/^description:[[:space:]]*/,""); print; exit}' "$skill_md")"

    [ -n "$name" ] || name="$dir"
    # 转义表格分隔符与换行，避免破坏 Markdown 表格
    desc="${desc//|/\\|}"

    echo "| [\`$name\`]($dir/) | ${desc:-（无 description）} |"
  done

  if [ "$found" -eq 0 ]; then
    echo "| _(暂无 skill)_ | |"
  fi
} > "$out"

echo "已生成 $out"
