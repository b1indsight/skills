# GPT‑6.2 提示指南：哪些建议值得迁移

核查日期：2026-11-24。OpenAI 的[通用提示工程指南](https://developers.openai.com/api/docs/guides/prompt-engineering)给出编写提示的基础方法；针对本代模型，优先读[《Using GPT‑6.2》中的 Prompting best practices](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#prompting-best-practices)。后者把示例作为 Astra 和 Sol 的试用起点，但对默认写作风格等行为的描述专门点名了 Astra。下面区分官方观察和建议用法；未对两个模型做效果对测。

## 旧提示词怎么改

| 何时值得改 | 官方指南的依据 | 建议用法（本文归纳） |
| --- | --- | --- |
| Astra 的研究结论很短，读者看不出依据 | [Writing style](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#writing-style)：Astra 默认较简洁；面向外部读者要补足背景，长任务的最终答复应能独立阅读。 | 检查旧提示中叠加的“尽量简短”。例如，给维护者的结论保留来源、适用版本和未验证项；有硬性字数上限时继续保留。 |
| 编码代理给出方案就停，或遇到小歧义反复求确认 | [Task completion](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#task-completion)：声明要完成的结果、可自行判断的事项和必须询问的决定，结束前验证。 | 把“解决这个 bug”具体化：用失败样例复现、修复并重跑；允许自行选择本地可逆的实现；若要改公共接口或写生产数据则暂停。 |
| 代码能跑，却破坏调用方依赖的行为，或带来多余抽象 | [Coding style](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#coding-style)：明确项目惯例、现有调用契约和测试缺口。 | 例如修复解析器时，把“已有调用者依赖空输入返回空列表”写入验收条件。运行相关测试；现有用例抓不到这次回归时再补一个。 |
| 前端结果符合功能要求，却偏离预期外观 | [Frontend design](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#frontend-design)：给出图像、字体或设计参考，渲染后对照调整。 | 用目标页面的参考图替换“设计得更专业”，点明要保留的字体层级与操作入口，要求对照实际渲染结果。 |

## 多轮 API：哪些问题要改调用方式

- **保留对话前缀。** 对 Astra 和 Sol，追加新要求，保持先前消息及工具调用不变。Responses API 检测到历史前缀被改写时会丢弃先前的推理项，可能导致重复计算或质量下降。已有输入保持可缓存，不代表每次都会命中缓存。见[官方发布说明](https://openai.com/index/introducing-gpt-6-2-astra-sol/)及[模型指南的 What’s new](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#whats-new)。
- **把稳定规则和单次要求放对位置。** 从 GPT‑6.2 起，Responses API 将顶层 `instructions` 追加到 `input` 之后。希望复用的规则（如仓库约定）放在 `input` 第一条 `developer` 消息；仅本次请求需要的开发者指令（如本轮输出格式）可以放在顶层 `instructions`。[迁移清单](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6.2-astra#migration-quickstart)也说明，两款模型调用工具都要用 Responses API。
- **单独选择模型和推理强度。** OpenAI [模型选择指南](https://developers.openai.com/api/docs/guides/model-selection)建议多数 API 工作流从 `gpt-6.2-sol`、`medium` 开始，要求高的工程或分析任务考虑 `gpt-6.2-astra`。Responses API 用 `reasoning.effort` 设置强度。长任务经常漏掉最后的检查时，可在写清验收条件之后再比较更高强度的效果。

## 怎么判断一条规则是否值得保留

OpenAI 建议[用代表性样例评估提示变更](https://developers.openai.com/api/docs/guides/prompting)。对本仓库的建议：先选一个确实发生过的失败样例，例如代理只报告“已修复”却没跑复现步骤。固定模型、推理强度和工具权限，只替换一条完成条件，比较它是否实际执行验证、是否在权限边界停下。在 Astra 和 Sol 上分别记录结果，再决定这条规则该写进通用 skill，还是只留在特定任务里。
