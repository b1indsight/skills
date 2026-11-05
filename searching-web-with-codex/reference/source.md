# Codex 源码来源与移植边界

本实现对应本机已安装的 Codex CLI 0.162.1，源码固定到
[rust-v0.162.1 的提交](https://github.com/openai/codex/commit/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d)。
没有以随时变化的 main 作为移植基线。

## 从哪里提取

| Python 部分 | Rust 原始实现 |
| --- | --- |
| HTTP POST 与响应解码 | [codex-api/src/endpoint/search.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/codex-api/src/endpoint/search.rs#L14-L47) |
| 请求、search/open/find/click 字段 | [codex-api/src/search.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/codex-api/src/search.rs#L9-L99) |
| 会话 ID、模型、输出预算和结果透传 | [ext/web-search/src/tool.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/ext/web-search/src/tool.rs#L95-L199) |
| cached/indexed/live 映射及 direct caller | [ext/web-search/src/extension.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/ext/web-search/src/extension.rs#L63-L105) |
| ChatGPT 服务地址 | [model-provider-info/src/lib.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/model-provider-info/src/lib.rs#L80), [认证模式选址](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/model-provider-info/src/lib.rs#L426-L446) |
| 认证文件结构 | [login/src/auth/storage.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/login/src/auth/storage.rs#L47-L74), [token_data.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/login/src/token_data.rs#L10-L24) |
| 命令限制和引用规则 | [web_run_description.md](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/ext/web-search/web_run_description.md) |

Codex 同时存在 [hosted web_search 工具声明](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/core/src/tools/hosted_spec.rs)。
本 skill 提取的是独立 `web.run` 客户端路径：将命令提交到 `alpha/search`，
不使用模型提示词来间接触发 hosted search。

## 移植内容

```json
{
  "id": "会话 UUID",
  "model": "明确配置的模型",
  "commands": {"search_query": [{"q": "查询"}], "response_length": "short"},
  "settings": {"allowed_callers": ["direct"], "external_web_access": true},
  "max_output_tokens": 6000
}
```

- `search` → `commands.search_query`，包含可选的 `recency` 和 `domains`。
- `fetch` → `commands.open`，包含 `ref_id` 及可选的 `lineno`。
- `find` → `commands.find`；`click` → `commands.click`。
- `cached` → `false`，`indexed` → `"indexed"`，`live` → `true`。
- 返回 `output` 和 `results`；附加 `session_id`，让下一次调用复用同一服务端会话。

搜索引擎、抓取、解析和引用存储由远端服务提供，公开客户端源码没有提供可离线运行的这些后端。
这里移植了请求协议和客户端调用逻辑，没有声称移植整个搜索引擎。

## 有意保留的差异

- Python 3 标准库单文件；无 Codex 子进程、OpenAI SDK、LLM 编排或第三方搜索供应商。
- 仅支持 ChatGPT 的 auth.json 登录，固定官方 HTTPS 地址；不复制 OAuth 刷新、keyring、
  API key、工作负载身份、managed workspace 路由或自定义 provider。
- 仅读取顶层模型名；不重建 Codex 的整个配置、profile 与策略解析系统。TOML 解析仅在
  需要读取配置时导入；没有 `tomllib` 的环境可通过 `--model` 或 `CODEX_WEB_MODEL` 运行。
- 不发送本地会话历史。上游的 [history.rs](https://github.com/openai/codex/blob/092d3acd6bec3e3a14bdc7e7a2810ab628ab759d/codex-rs/ext/web-search/src/history.rs)
  会截取最近的用户/助手消息；本工具只提交用户选定的查询和 URL。
- 不发送遥测、turn metadata 或 Codex originator；使用自己的 User-Agent。
- 不自动重试或跟随 API 重定向，保留 TLS 校验，限制响应大小；错误不回显响应体和凭据。
- 不导出 `encrypted_output`。上游独立工具也只把文本作为工具输出传回。
- 省略图片、截图、财经、天气、体育、位置、混合命令批次及配置过滤器等非本任务能力。
  查询域名过滤通过 `search_query[].domains` 保留。
- socket 超时不等于整个操作的严格总时限。服务端返回正文错误时，客户端不臆测业务状态；
  调用者必须阅读 `output`。

## 验证记录

2026-11-05，在当前机器的 Python 3.13 和现有 ChatGPT 登录下执行：

| 场景 | 观察结果 |
| --- | --- |
| live 搜索 Python urllib 官方文档，限定 docs.python.org | 返回 12 个结构化文本结果，含真实 URL 和 `turn0search0` |
| 同一会话 fetch `turn0search0`，传入 line 30 | 返回 Python 官方 HOWTO，含行号和 `turn1view0` |
| 同一会话 find `turn1view0` 中的 timeout | 返回 `turn2view0` 及匹配区域 |
| 同一会话 click `turn1view0` 的链接 3 | 返回 IETF 的 RFC 2616 页面，引用为 `turn3view0` |
| 新会话直接 fetch 公共 URL | 返回页面正文和 `turn0view0` |

这是当次账号可用性的观察，不保证其他账号或未来版本可用。引用跨调用复用已验证，
服务端引用的保留时长没有确定契约。

离线测试覆盖请求字段与模式、各子命令、引用会话要求、非法参数、只读认证、
模型优先级、错误脱敏、不重试、响应格式和大小，以及 301/302/303/307/308 不跳转。

## 许可证

上游为 Apache-2.0。本目录携带原 LICENSE 和 NOTICE；Python 文件注明翻译修改。
网络服务的使用权限与配额不由源码许可证授予。
