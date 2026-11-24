# hooks 与 skill 资产规则

> 板块 `agent-config` · 本页承载 2 条条目：`agent-config/hook-scripts`（L3 · should · 旧 `R034`）· `agent-config/skill-metadata`（L3 · should · 旧 `R035`）
> 讲解与依据见 [guide/04 · Agent 怎么用](../../../guide/04-Agent怎么用.zh-CN.md)。
> 通用术语与具体文件名的对应见 [机制对照表](../../mechanism-map.md)（附录，非规范）。

## 一句话

hooks 和 skills 都是**配置里的一行指向磁盘上的一个东西**：前者指向脚本，后者指向 `SKILL.md`。
这类"声明指向资产"的结构有一种共同的失效方式——**指向不存在的东西时不报错**。
hook 路径写错，门禁静默消失，比从来没配过 hook 更危险；skill 缺 `description`，它不会被自动命中，
于是整套流程只在"有人记得"的时候才生效。本页两条判据就是把这两种静默失效变成可核对的两眼活。

## 共同失效模式：引用断了，没人知道

| 资产 | 声明在哪 | 断掉时的表现 | 谁能发现 |
|---|---|---|---|
| hook 脚本 | 共享工具配置文件里的 `hooks` 配置 | 事件照常触发，脚本不运行，**没有任何地方报错** | 只有"故意触发一次"的人 |
| skill | 工具专属资产目录下的 `<name>/SKILL.md` 或 `.github/skills/` | 文件在，但没有 `description`，模型无从判断何时用 | 只有手动调用它的人 |

两条判据因此都是**存在性 + 一致性**，不是质量判断：脚本在不在、字段有没有。这和整个规范的口径一致——
只写结构性判据（文件在不在、字段有没有），不写需要主观判断的条目（见 [spec/README](../../README.md)「判定靠什么」）。

## hooks：配置指向脚本

`agent-config/hook-scripts` 的判据只有一句：hooks 引用的脚本存在。落地时三件事：

1. **路径以仓库根为基准写相对路径。** 绝对路径和个人目录属于机器本地状态，写进共享配置就违反了
   "不提交个人配置"这条硬约定（见 [AGENTS.md 写法](../writing/agents-md.md) 与 [目录与 agent 文件](../layout/agent-files.md)）。
2. **改完必须故意触发一次。** 这是唯一能证明"这条 hook 真的会拦"的动作——也是本条判据的验收方式。
   光看配置文件看不出脚本是不是 404。
3. **脚本存在 ≠ 会阻断。** 脚本在、跑起来了、退出码用错，照样放行。那是
   [`agent-config/gate-hook`](permissions.md) 管的事，两条要一起过。

一个具体的坑：`AGENTS.md` 里"禁区"这一节，[templates/AGENTS.md.tmpl](../../../templates/AGENTS.md.tmpl) 的标题写的是
**"禁区（由 hooks 与 CI 强制）"**。这句话是一个**承诺**——文档声称有东西在强制，读者就会信。
如果 hooks 指向的脚本不存在，这个承诺当场变成假的，而且假得没有声音。
所以"文档里写了由 hooks 强制"和"hooks 引用的脚本存在"必须一起核对。

## skill：frontmatter 指向一次命中

`description` 是 skill 被自动命中的唯一依据（上游加载机制，本库证据文件未收录 Skills 原文）。所以它要回答的是**"什么时候用我"**，
不是"我是什么"。可核对的写法差异：

| | 示例 | 模型能否据此命中 |
|---|---|---|
| 反例 | `description: PR 助手` | 不能——它说的是身份，不是触发条件 |
| 反例 | `description: 一些有用的检查` | 不能——没有可判断的边界 |
| 正例 | `description: 用本地仓库开 PR、修冲突直到合并。当需要开/改/合 PR，或遇到 422 head invalid、No commits between main 与 branch 时加载。` | 能——列了**动作**与**报错特征**两类触发条件 |

（上表是构造示例，不是对任何真实仓库的引用。）

配套的 `name`：短横线小写，和目录名对得上，便于人在会话里手动点名。
判据只要求 `name` 与 `description` 两个字段存在且非空——**内容好不好属于判断力，不属于清单**。

写 `description` 时把"什么时候**不**该用"也写进去，命中率明显更稳：
两个 skill 的触发条件重叠时，模型只能猜。

## 什么该进 skill，什么该进根文件

[guide/04 §1.3](../../../guide/04-Agent怎么用.zh-CN.md) 给的判断标准一句话：
**每次都要知道 → 根文件；做某件事时才需要 → skill。** 官方明确建议把团队流程放进 skills，
因为流程只在被调用时加载，不占日常上下文。

这条取舍有成本账：上下文越满，判断质量越差（§4）。所以"把多步流程搬进 skill"不是洁癖——
[AGENTS.md 写法](../writing/agents-md.md) 那条"根文件不超过预算"的判据，正路就是把流程搬出去。
反过来也成立：**别把每次都要用的三条命令塞进 skill**，那样 agent 每次都得先猜"有没有相关 skill"。

## 放哪：工具专属资产目录 还是 `.github/`

实测里 agent 资产有两种放法：`cli/cli` 与 `microsoft/vscode` 放 `.github/agents`、`.github/skills`，
只服务单一工具的那套放工具专属资产目录（[guide/02 §5](../../../guide/02-目录结构.zh-CN.md)）。判断规则记一条就够：

> **只有这一个工具用的 → 工具私有目录；任何别的工具也可能用的 → `.github/`。**

| 资产 | 单工具专属（工具专属资产目录） | 多工具（`.github/`） |
|---|---|---|
| 权限与 hooks | 共享工具配置文件 + hooks 配置 | `.github/hooks/`（vscode 的做法） |
| 可复用流程 | 工具专属资产目录下的 `<name>/SKILL.md` | `.github/skills/`（cli/cli、vscode） |
| 分主题规则 | 分层机制（按路径生效的规则文件） | `.github/instructions/*`（vscode） |

工具专属资产目录与 `.github/` 各存一份 agent 规则 = 双事实源，随机生效——这是 [guide/02](../../../guide/02-目录结构.zh-CN.md)
反例表里的原条目，也是 [各工具的指令面](surfaces.md) 那篇的主题。这些文件该不该提交进版本库，见
[目录与 agent 文件](../layout/agent-files.md)；具体目录名与文件名见 [机制对照表](../../mechanism-map.md)。

## 常见误判与本库的诚实说明

| 误判 | 问题 | 改法 |
|---|---|---|
| "配置里有 hooks 这一段，就说明有门禁" | 脚本可能不存在，或存在但不阻断 | 两条一起过：脚本在（本页）+ 违规分支用阻塞退出码（[permissions.md](permissions.md)） |
| hook 报错就默认放行 | 崩溃和"没违规"看起来一模一样 | 需要"崩了也拦住"就加 `onFailure: "block"`（[guide/04 §3](../../../guide/04-Agent怎么用.zh-CN.md)） |
| skill 只写正文不写 frontmatter | 内容再好也不会被自动命中 | 先补 `name` + `description`，再谈正文 |
| 用 skill 承载"绝不能有例外"的约束 | skill 是模型选择要不要调用的，仍是提示 | 那条约束升级到 [权限与 hook 门禁](permissions.md) |
| 给本库提 PR 加检查脚本 | 本库不提供规则校验器（[ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md)） | 想自动化就另建仓库消费本清单 |

**本库这两条都不适用。** [ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md) 把本库自带的
工具专属资产目录（settings、hooks、skills、commands）整体删掉了，所以现在**本库里没有任何 hook 脚本，也没有任何 skill**；
唯一的自动化是 `.github/workflows/docs.yml` 的两个必需检查，它们只校验文档自身。
本页举的写法来自给被指导仓库的 [templates/AGENTS.md.tmpl](../../../templates/AGENTS.md.tmpl)、官方文档摘录
[证据摘录](../../../docs/evidence/2026-11-17-claude-code-docs.md)（hooks 与确定性部分），
以及上游 Skills 的公开加载机制（frontmatter 的 `name` / `description`——该摘录未收录 Skills 一节）。

## 条目

### 若配了 hooks：hooks 引用的脚本存在

`agent-config/hook-scripts` · L3 · should · 旧 `R034`

**为什么。** hook 指向不存在的脚本时，门禁静默失效，比没有 hook 更危险。

**怎么做。** 修正路径，或删除该 hook；改动后故意触发一次确认拦住。

### 若用 skill：skill 带 name 与 description

`agent-config/skill-metadata` · L3 · should · 旧 `R035`

**为什么。** description 是 skill 被自动命中的唯一依据，缺了就只能靠人记得输入命令。

**怎么做。** 补 frontmatter：name（短横线）、description（写清何时使用）。

## 相关

- [权限与 hook 门禁](permissions.md) — 脚本存在之后，违规分支还得返回阻塞退出码才真的拦得住
- [各工具的指令面](surfaces.md) — 指令文件只放指针，流程与资产放这里
- [目录与 agent 文件](../layout/agent-files.md) — 工具专属资产目录与 `.github/` 下的资产哪些进版本库
- [AGENTS.md 写法](../writing/agents-md.md) — 根文件的预算，以及"流程搬出去"的正路
- [机制对照表](../../mechanism-map.md) — 通用术语 ↔ 具体目录与文件名（附录，非规范）
- [guide/04 · Agent 怎么用](../../../guide/04-Agent怎么用.zh-CN.md) — §1.3 根文件 vs skill、§3 hook 的类型与 `onFailure`
- [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md) — 两种放法的实测对照
