# 机制对照表（附录 · 非规范）

> 本表把规范正文的**通用术语**对应到具体工具的机制。
> **它不是规范**：不承载判据、不参与符合性声明、允许过期。
> 工具名在本库里只出现在本附录与 `docs/evidence/`（见 [ADR-0014](../docs/adr/0014-tool-neutral-spec.md)）。
> 按读者工具群增删；快照日期 2026-11-24。

| 通用术语（规范正文用词） | 具体机制示例（示例而已） |
|---|---|
| 主体指令文件 | `AGENTS.md`（开放约定：Codex CLI、DeepSeek Harness 等原生读；Gemini CLI 可配置读） |
| 工具专属指令文件 | `CLAUDE.md`、`GEMINI.md` |
| 平台级指令文件 | `.github/copilot-instructions.md` |
| 分主题指令文件 | `.github/instructions/*.instructions.md` + `applyTo` |
| 工具专属资产目录 | `.claude/`、`.gemini/`、`.cursor/` |
| 共享工具配置文件 | `.claude/settings.json` |
| 个人覆盖文件 | `.claude/settings.local.json`、`CLAUDE.local.md` |
| 门禁 hook | Claude Code hook（exit code 2 拦截） |
| 权限声明（deny 清单） | `.claude/settings.json` 的 `permissions.deny` |
| 机器本地记忆 | Claude Code auto memory |
| 会话署名 trailer | `Co-Authored-By: <model> <noreply 地址>` |
| 分层机制 | `.claude/rules/*.md` + `paths:`、`.github/instructions/*.instructions.md` + `applyTo` |

## 出处

- Codex CLI 读 `AGENTS.md`（全局 + 仓库嵌套最近优先）：[OpenAI Codex 文档](https://learn.chatgpt.com/docs/agent-configuration/agents-md)、[agents.md](https://agents.md)
- Gemini CLI 默认 `GEMINI.md`，`context.fileName` 可配成含 `AGENTS.md` 的列表：[Gemini CLI 文档](https://geminicli.com/docs/cli/gemini-md)
- 其余行的原始证据见 [`docs/evidence/`](../docs/evidence/)（`2026-11-17-claude-code-docs.md` 等）
