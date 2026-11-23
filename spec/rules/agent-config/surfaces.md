# 各工具的指令面规则

> 板块 `agent-config` · 本页承载 2 条条目：`agent-config/claude-md-thin`（L3 · should · 旧 `R033`）· `agent-config/copilot-instructions`（L3 · may · 旧 `R046`）
> 讲解与依据见 [guide/04 · Agent 怎么用](../../../guide/04-Agent怎么用.zh-CN.md)。

## 一句话

一个仓库里可能同时躺着好几份"给 agent 读的说明"，而**它们不该并列**：`AGENTS.md` 是主体，
其余每一个工具的指令文件都只是**适配层**——把主体接过来，再加几条只有那个工具才会执行的东西。
并列就是双事实源：同一件事有两份写法，agent 读到哪份算哪份，而你会在 review 里反复修同一个问题。
本页两条判据管的是同一件事的两端：**细则只放一处**，另一处只放指针。

## 指令面清单：谁读哪一份

| 文件 | 谁会读 | 本库立场 |
|---|---|---|
| `AGENTS.md`（根） | 多数 agent 默认读根目录 | **主体**。存在性与内容见 [文档必备项](../documents/essentials.md) 与 [AGENTS.md 写法](../writing/agents-md.md) |
| `CLAUDE.md` | 若你用 Claude Code | 薄适配层：第一行指向 `AGENTS.md`，只留该工具专属补充（本页 `agent-config/claude-md-thin`） |
| `.github/copilot-instructions.md` | 若你用 Copilot | 与 `AGENTS.md` **二选一**放细则，另一处只放指针（本页 `agent-config/copilot-instructions`） |
| `.github/instructions/*.instructions.md` + `applyTo` | 若你用 Copilot | 分主题指令的正路（这套语法是 GitHub Copilot 官方机制，本库证据文件未收录其原文）；实测体积见 [2026-11-18 采样](../../../docs/evidence/2026-11-18-agent-docs-sampling.md) |
| `.claude/settings.json`、`.claude/rules/*.md` | 若你用 Claude Code | 只服务这一个工具的资产才进 `.claude/`；该不该提交见 [目录与 agent 文件](../layout/agent-files.md) |
| auto memory（工具本机） | 若你用 Claude Code | **机器本地，不跨机器共享**——不能当事实源。原文见 [Claude Code 文档摘录](../../../docs/evidence/2026-11-17-claude-code-docs.md) |

放哪一条判断规则就够：**只有这一个工具用的 → 工具的私有目录；任何别的工具也可能要的 → 公共位置。**
完整对照表在 [guide/02 §5](../../../guide/02-目录结构.zh-CN.md)。

## 所有指令面都只是提示

这一点决定了本页为什么只要求"别双写"，不要求"写得更严"。官方文档的原话是：
`CLAUDE.md` files… Claude treats them as **context, not enforced configuration**
（[Claude Code 文档摘录](../../../docs/evidence/2026-11-17-claude-code-docs.md) §2）。

也就是说：不管你把同一句话写进 `AGENTS.md`、`CLAUDE.md` 还是 `copilot-instructions.md`，
它的执行强度都是**模型自己决定**那一档。写三份不会更硬，只会三份不一致。
"绝不能有例外"的那几条要升级到确定性机制，那是 [权限与 hook 门禁](permissions.md) 的事。

推论很直接：**指令面的优化目标是"准"和"短"，不是"多"。**
[guide/04 §1](../../../guide/04-Agent怎么用.zh-CN.md) 给的口径是根文件只写"模型看不到、又每次都要用"的东西；
超过预算就分层或改路由（判据见 [AGENTS.md 写法](../writing/agents-md.md)）。

## 细则只有一处——但"哪一处"可以反过来

实测里两种方向都有人做，**共同点才是判据**：

| 仓库 | 实测（2026-11-18 快照） | 谁是主体 |
|---|---|---|
| `microsoft/vscode` | `AGENTS.md` **8 行 / 0.5 KB**，`.github/copilot-instructions.md` **14.5 KB** | Copilot 文件是主体，`AGENTS.md` 是路由层 |
| `supabase/supabase` | `AGENTS.md` **7 KB / 78 行**，`copilot-instructions.md` **6.5 KB** | 两份都在写细则——体积上看不出谁是主体 |
| `denoland/deno` | `CLAUDE.md` **11.6 KB** + `copilot-instructions.md` **12.3 KB** | 两份都超过 10 KB，几乎不可能互为指针 |

vscode 那 8 行值得抄，它只做两件事：**指向真正的细则**，以及**把最容易做错的那一条直接写在门口**。
注意它的方向和 `agent-config/claude-md-thin` 相反（那条要求 `AGENTS.md` 厚、`CLAUDE.md` 薄）——
这不矛盾：**判据不是"谁厚"，是"同一句细则只有一个归属地"**。本库选 `AGENTS.md` 当主体，
因为它是跨工具的那一份；若你的团队只有 Copilot，反过来也成立，但只该有一处。

## 薄到什么程度算薄

"要薄"没法核对，所以给一个可执行的算法。**把适配层逐行拿去主体文件里搜：**

| 搜索结果 | 这一行是什么 | 处理 |
|---|---|---|
| 主体里搜得到 | 双写 | 删掉，只留指针 |
| 搜不到，但**把工具名换成别的工具，这句话仍然成立** | 通用约定，只是写错了地方 | 搬进主体 |
| 搜不到，且**只有这个工具会执行它** | 合法残留 | 留下 |

第三类是适配层存在的唯一理由，具体只有这几种东西算：该工具专有的设置名与开关、
专有的 slash command、专有的 hook 事件名、专有的权限语法。
"这个项目用 pnpm 不用 npm" 不是——换任何工具都要用 pnpm，它属于 `AGENTS.md` 的命令表。

再加两条形式检查，都能一眼看出：

1. **第一行是指针。** `@AGENTS.md` 或等价的一行指向；没有指针的适配层默认就是第二事实源。
2. **适配层里没有小节标题。** 一旦长出 `## 命令`、`## 代码风格` 这种标题，它就在长主体，
   下一步一定是两份开始漂移。真需要分主题，用工具自己的分层机制（如 `.claude/rules/*.md` + `paths:`、
   `.github/instructions/*.instructions.md` + `applyTo`），不要塞回适配层。

体积只能当参照，不能当阈值：本库证据里被当作"薄"的样本是 8 行 / 0.5 KB，反面样本是两份都超过 10 KB。

## 不绑定工具：判据为什么都以"若用"开头

本库的硬约定是**不默认读者的 agent 工具**；需要提到具体工具时写成条件式（"若你用 Claude Code…"）。
本页两条判据句就是这条约定的产物：`若用 Claude Code：CLAUDE.md 是薄适配层`、
`若用 Copilot：仓库级指令文件存在，且不与 AGENTS.md 双写`。
这个措辞不是修辞，它改变判定结果：

| 你的情况 | 判定 |
|---|---|
| 不用 Claude Code，仓库里没有 `CLAUDE.md` | **不适用**，不是不合格 |
| 用 Claude Code，`CLAUDE.md` 里抄了一份命令表和风格说明 | 不合格：双事实源 |
| 不用 Copilot，没有 `copilot-instructions.md` | **不适用**（这条本身也只是 `may`） |
| 用 Copilot，细则在 `AGENTS.md`，`copilot-instructions.md` 只有一句指向它 | 合格 |

所以读这两条时先问"我用不用这个工具"，再问"我做了没有"。
[ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md) 删掉本库自带的 `.claude/` 与 `CLAUDE.md`，
正是为了让规范不替读者选工具。

## 常见误判

| 误判 | 问题 | 改法 |
|---|---|---|
| "两份都写全，谁读到都能用" | 双事实源，agent 随机选一个生效，漂移没人发现 | 一处细则 + 一处指针 |
| 把 agent 指令写进 `README.md` | 工具读不到，人看着是噪音 | 拆出 `AGENTS.md`（见 [guide/02](../../../guide/02-目录结构.zh-CN.md) 的反例表） |
| 适配层"先复制一份，回头再删" | 回头不会删，三个月后两份已经不一样了 | 第一天就只写指针 |
| 子目录适配层各写一份根约定 | 加载后互相矛盾，行为漂移 | 子文件只写"这一目录的差异" |
| 指望指令面挡住 agent 改门禁 | 它是 context，不是 enforced configuration | 升级到 [权限与 hook 门禁](permissions.md)，最后一道是 [分支保护规则](../settings/branch-protection.md) |

## 条目

### 若用 Claude Code：CLAUDE.md 是薄适配层

`agent-config/claude-md-thin` · L3 · should · 旧 `R033`

**为什么。** CLAUDE.md 与 AGENTS.md 各写一份会形成双事实源，agent 随机选一个生效。

**怎么做。** CLAUDE.md 第一行写 @AGENTS.md，只保留 Claude 专属的少量补充。

### 若用 Copilot：仓库级指令文件存在，且不与 `AGENTS.md` 双写

`agent-config/copilot-instructions` · L3 · may · 旧 `R046`

**为什么。** 实测里 `.github/copilot-instructions.md` 在头部仓库是主战场：`microsoft/vscode` 14.5 KB、`denoland/deno` 12.3 KB、`supabase/supabase` 6.5 KB。本库早期清单里这一条**零条**（`guide/02` 只在表格里带过），1.5.0 才补上 `R046`——证据先于规则，这条本身就是补上的产物。

**怎么做。** 细则只放一处（`AGENTS.md` 或 `.github/copilot-instructions.md`），另一处只放指针；分主题指令用 `.github/instructions/*.instructions.md` + `applyTo`。证据：[2026-11-18 采样](../../../docs/evidence/2026-11-18-agent-docs-sampling.md)。

## 相关

- [权限与 hook 门禁](permissions.md) — 指令面拦不住的东西，靠这两道闸
- [hooks 与 skill 资产](hooks-skills.md) — 多步流程与按需资产，别塞回根文件
- [文档必备项](../documents/essentials.md) · [AGENTS.md 写法](../writing/agents-md.md) — 主体文件本身该有什么、多长
- [目录与 agent 文件](../layout/agent-files.md) — 这些文件放哪、哪些进版本库
- [guide/04 · Agent 怎么用](../../../guide/04-Agent怎么用.zh-CN.md) — 短、分层、按需
- [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md) — `.claude/` 与 `.github/` 的分工表
- [2026-11-18 采样](../../../docs/evidence/2026-11-18-agent-docs-sampling.md) — 体积与四种形态的实测
