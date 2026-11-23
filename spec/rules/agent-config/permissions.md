# 权限与 hook 门禁规则

> 板块 `agent-config` · 本页承载 2 条条目：`agent-config/permissions-deny`（L2 · should · 旧 `R026`）· `agent-config/hook-exit-2`（L3 · may · 旧 `R040`）
> 讲解与依据见 [guide/04 · Agent 怎么用](../../../guide/04-Agent怎么用.zh-CN.md)。

## 一句话

**给 agent 立规矩有两种执行强度：写在配置里的声明式禁止，和跑在关键路径上的过程式拦截。**
前者是一行 `deny`，后者是一段脚本加一个退出码。它们不是"松紧两档"，而是**覆盖范围不同的两道闸**：
`deny` 只能表达"能事先枚举的目标"，hook 才能表达"要算一下才知道违不违规"。
只装一道，另一道管的事就悄悄退回文档里去了——而文档是提示，不是闸门。

## 两道闸分别是什么

[guide/04 §0](../../../guide/04-Agent怎么用.zh-CN.md) 把每一条给 agent 的指令分成"模型自己决定"和"harness 强制执行"两类。
本页这两条都属于**确定性**那一侧——不管模型怎么想，每一次都执行。但它们的执行方式不同：

| | 声明式禁止（`deny`） | 过程式拦截（hook + `exit 2`） |
|---|---|---|
| 谁来判 | 工具本体按规则匹配这次调用 | 你的脚本自己判 |
| 能表达什么 | 工具名 + 路径 / 命令的**字面模式** | 任意逻辑：读 diff、看当前分支、跑一遍 formatter |
| 判断成本 | 零代码，一行配置 | 一个脚本，加上长期维护它 |
| 典型失效 | 模式没覆盖到的写法直接放行 | 脚本路径不存在、退出码用错、异常时默认放行 |
| 对应条目 | `agent-config/permissions-deny`（L2 · should） | `agent-config/hook-exit-2`（L3 · may），脚本本身的存在性由 `agent-config/hooks-scripts` 管 |

[guide/04 §3](../../../guide/04-Agent怎么用.zh-CN.md) 抄的是官方那三个例子，正好一条一例：
"不要读 `.env`" 用 `permissions.deny: ["Read(./.env)"]`；"改完必须格式化" 用 `PostToolUse` hook 直接跑 formatter；
"不要动 `migrations/`" 两条路都行——`Edit(./migrations/**)` deny，**或** hook 里 `exit 2`。
第三个例子可以二选一，前两个不行：`.env` 不需要算，格式化算不了成"要不要做"。

## 为什么两个都要

**只有 `deny` 会漏掉"要算才知道"的违规。** 这类规矩没法写成路径模式："提交前必须跑过 lint"、
"不许在 `main` 上直接 commit"、"改了 `CHANGELOG.md` 就得同时改版本号"——它们要读上下文才能判。
于是它们只能留在 `AGENTS.md` 里当提示，而提示是可以被忽略的。

**只有 hook 会把门禁变成一段会坏、会指错、会不阻断的代码。** hook 是脚本，脚本有 bug：
路径写错时它根本不运行（`agent-config/hooks-scripts`），退出码用错时它运行了但拦不住（本页 `agent-config/hook-exit-2`）。
`deny` 的价值恰恰是**零代码**——没有东西可以坏。

所以顺序是固定的：**先写 `deny`，把 `deny` 表达不了的少数几条升级成 hook。**
[guide/04 §3](../../../guide/04-Agent怎么用.zh-CN.md) 还有一句配套的约束：确定性手段是**稀缺资源**，
只给"绝不能有例外"的规则用，否则仓库会变成不可维护的规则迷宫；§5 的反例第一条就是"把所有规则都写成 hook"。

## 阻塞只有一种写法

`exit 2` 之所以单独成条，是因为**另外两种退出码看起来都像在工作**：

| 退出码 | 实际效果 | 什么时候用 |
|---|---|---|
| `0` | 放行，输出只进日志 | 记录、注入上下文 |
| `1` | **非阻塞**错误：报错被显示出来，流程照走 | 警告，且你接受它继续 |
| `2` | **阻塞**：这次调用被拦下 | 真正的门禁 |

三个退出码与 stderr 反馈通道的语义出自官方 Hooks reference
（[code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)，与
[guide/05 附录](../../../guide/05-Agent参与怎么管理.zh-CN.md) 引的是同一条链接）；
本库摘录里只落了 `exit 2`（[guide/04 §3](../../../guide/04-Agent怎么用.zh-CN.md)），`0` / `1` 两行是上游定义。

写 `1` 的 hook 是最阴险的一种：它有日志、有报错、CI 里看着也红，但 agent 该改的文件一个都没被拦住。
判据因此不是"有没有 hook"，而是"违规分支是不是 `exit 2`"。

还有一条配套的：**写 stderr 再 `exit 2`**。stderr 是这条 hook 唯一的反馈通道——只 `exit 2` 不写 stderr，
模型只知道被拦了，不知道为什么，于是它会换个写法再试一次，而不是去修真正的问题。
[guide/04 §3](../../../guide/04-Agent怎么用.zh-CN.md) 另外提醒两点：`prompt` / `agent` 类型的 hook **仍然是模型判断**，
要强制就用 `command` / `http`；如果"hook 自己崩了也必须拦住"，加 `onFailure: "block"`。

## 常见误判

| 误判 | 为什么错 | 怎么改 |
|---|---|---|
| "`allow` 收紧了就等于有门禁" | `allow` 管的是哪些调用不用问，`deny` 管的才是"绝对不行"。本库模板把 `deny` 写在 `allow` 前面，口径见 [目录与 agent 文件](../layout/agent-files.md) | 显式写出禁止项——它是可核对的：文件里有没有那几行 |
| 只 deny 文件，不 deny 解释器 | `Read(./.env)` 挡住了读文件，但一条 shell 就能读它。[templates/settings.json.tmpl](../../../templates/settings.json.tmpl) 里连 `Bash(sh *)`、`Bash(bash *)` 都封了，就是这个口子 | 路径模式和执行入口一起封；封不住的交给 hook |
| 以为 `deny` 是最后一道防线 | `deny` 匹配的是**字面写法**，换个调用方式就绕过了。真正的最后一道是平台闸门：[分支保护规则](../settings/branch-protection.md) | `deny` 当第一道，分支保护当最后一道，两道都要有 |
| 用 hook 去做"规范体检" | 那是另一件事。本库明确不提供规则校验器（[ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md)），hook 只拦"这一次调用" | 想自动化就另建仓库消费本清单 |
| agent 的凭证跟着门禁一起配 | 门禁拦操作，凭证决定拦不住时的爆炸半径 | 见 [凭证规则](../governance/ownership.md) |

## 本库的诚实说明

**本库这两条都不适用，而不是"已满足"。** [ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md) 把
`.claude/`（settings、hooks、skills、commands）与 `CLAUDE.md` 全部删掉了，理由写在它的第 3 条后果里：
自带这些等于默认读者用 Claude Code，而这份规范的立场是工具中立。
所以本库现在**没有任何 `permissions.deny`，也没有任何 hook**；本页举的例子全部来自
[templates/settings.json.tmpl](../../../templates/settings.json.tmpl)（给**被指导仓库**复制的模板）与官方文档摘录
[Claude Code 文档摘录](../../../docs/evidence/2026-11-17-claude-code-docs.md)。
本库唯一真正硬的东西是平台侧那道闸：`main` 的 ruleset 加两个必需检查（链接检查 / 双语配对），
见 [分支保护规则](../settings/branch-protection.md)。

## 条目

### 若用 Claude Code：permissions.deny 非空

`agent-config/permissions-deny` · L2 · should · 旧 `R026`

**为什么。** 没有 deny 就是全开；密钥路径与破坏性命令必须先封。

**怎么做。** 至少 deny：Read(./.env)、Read(./secrets/**)、Bash(rm *)、Bash(git reset *)。

### 若用 hooks：hook 脚本使用 exit 2 阻塞

`agent-config/hook-exit-2` · L3 · may · 旧 `R040`

**为什么。** 阻塞类 hook 不收 exit 2 就等于没检查：exit 0 只进日志，exit 1 是非阻塞错误。

**怎么做。** 违规分支改为写 stderr 后 exit 2。

## 相关

- [各工具的指令面](surfaces.md) — 哪些规矩只能写成提示，哪些必须升级成本页这两道闸
- [hooks 与 skill 资产](hooks-skills.md) — hook 指向的脚本得真的存在，否则本页第二道闸是空的
- [目录与 agent 文件](../layout/agent-files.md) — `.claude/settings.json` 该不该提交进版本库
- [分支保护规则](../settings/branch-protection.md) — 平台侧的最后一道闸门
- [凭证规则](../governance/ownership.md) — 拦不住时的爆炸半径
- [guide/04 · Agent 怎么用](../../../guide/04-Agent怎么用.zh-CN.md) — §0 两类指令、§3 官方三例、§5 反例
- [Claude Code 文档摘录](../../../docs/evidence/2026-11-17-claude-code-docs.md) — 确定性 / 非确定性的原文依据
