# AGENTS.md 内容规则

> 板块 `writing` · 本页承载 5 条条目：`writing/agents-md-length`（L3 · should · 旧 `R030`）·
> `writing/agents-md-commands`（L3 · should · 旧 `R031`）· `writing/agents-md-boundaries`（L3 · should · 旧 `R032`）·
> `writing/agents-md-paths`（L3 · should · 旧 `R037`）· `writing/agents-md-language`（L3 · may · 旧 `R042`）
> 讲解见 [guide/03 · 文档该怎么写](../../../guide/03-文档该怎么写.zh-CN.md)。

## 一句话

`AGENTS.md` 是仓库里**唯一每次会话被全文加载**的文件，所以它的判据不是"写得全不全"，而是"每一行有没有被用到"。
五条条目管同一件事的五个面：**长度是预算**（超了是位置错，不是内容多）· **命令要有唯一权威** ·
**禁区要能被机器对上** · **引用路径要真实存在** · **输出语言声明一次**。
"这个文件该不该存在"不在本页——那是 [根目录规则](../documents/essentials.md)。

## 只有一个读者画像：每次会话全文加载

[guide/03 §0](../../../guide/03-文档该怎么写.zh-CN.md) 把文档读者分层，`AGENTS.md` 那一行和其他四行不是一类东西：

| 读者 | 他怎么读 | 能容忍的长度 |
|---|---|---|
| 陌生人 | 只看 README 前 20 行 | 很短 |
| 使用者 | 查 docs、CHANGELOG | 中等 |
| 贡献者 | 读 CONTRIBUTING + PR 模板 | 中等 |
| **agent** | **每次会话全文加载** | **严格（≤200 行）** |
| 未来的维护者 | 翻 ADR、git log | 不限 |

两个直接推论：

1. **同一份内容不要写给两个读者。** README 里塞 agent 指令，人看着是噪音，agent 也读不到——它不加载 README。
2. **agent 是唯一"每次都完整读一遍"的读者**，所以按上下文预算写，不按完备写。
   [guide/04 §4](../../../guide/04-Agent怎么用.zh-CN.md) 给了机制：**上下文越满，判断质量越差**。

200 行不是拍脑袋，但也不是行业铁律——它是"每次会话都要付费"换算出来的。真实分布见
[docs/evidence/2026-11-18-agent-docs-sampling.md](../../../docs/evidence/2026-11-18-agent-docs-sampling.md)
（2026-11-18 默认分支快照，12 仓便利样本）：

| 仓库 | 文件 | 行数 | 形态 |
|---|---|---:|---|
| microsoft/vscode | `AGENTS.md` | 8 | 路由型：指向别处 + 门口写最容易做错的那一条 |
| python/cpython | `AGENTS.md` | 30 | |
| kubernetes/kubernetes | `AGENTS.md` | 40 | 沟通偏好 + 约束 + 命令 + 风格 |
| anthropics/claude-code | `CLAUDE.md` | 41 | |
| openai/openai-python | `AGENTS.md` | 60 | 所有权 + 安全 + 验证 |
| supabase/supabase | `AGENTS.md` | 78 | |
| cli/cli | `AGENTS.md` | 105 | 三条边界最显眼 |
| rust-lang/rust | `AGENTS.md` | 266 | 样本里唯一超 200 行的 |
| vercel/next.js · modelcontextprotocol/servers | `AGENTS.md` | 33.6 KB · 50 KB | 大全型，根文件承载全部约定，无分层 |

那份报告自己写明：样本**非随机、非分层**，12 个里 4 个是 GitHub / Anthropic 生态的仓库，它支撑"存在哪些形态"，
**不支撑**"多数仓库如此"。所以这张表的正确读法不是"别人都多少行"，而是：**8 行到 266 行都有人在用**，
200 行是这条分布里"仍然可维护"的上沿，不是达标线。

本仓库自己的活样本：`AGENTS.md` 实测 **107 行 / 8259 字节 / 10 个二级标题**（2026-11-20 本次重写时测得，
LF 行尾、无 BOM）。骨架是八段，实际十段——多出来的两段是「提交与 PR」和「main 的保护配置」，
两段都是"动手之前必须看见"的门禁信息，不是知识。

## 八段骨架，与本仓库的实测对照

[guide/03 §2](../../../guide/03-文档该怎么写.zh-CN.md) 给的骨架顺序别乱。左列是骨架，右列是本仓库 `AGENTS.md` 的实际写法：

| 段 | 写什么 | 本仓库的实际做法 |
|---|---|---|
| 项目是什么 | 2–3 行，只写无法从代码推断的定位与边界 | "纯规范文档库"、"不含规则引擎"、"不绑定任何语言或工具" |
| 语言约定 | 声明一次，靠前 | 5 条：默认文件英文 / 中文镜像 `*.zh-CN.md` / 协作过程用中文 / 不翻译清单 / 冲突怎么裁 |
| 命令（唯一权威，勿自行发明） | 表格 + 失败常见原因 | **一个没有命令的仓库也写了这一节**，见下 |
| 目录地图 | 哪个目录做什么、哪里有雷 | `guide/` `spec/` `spec/rules/` `templates/` `docs/` `.github/` |
| 硬约定 | 可验证的规矩 | 6 条，含"一条规则只有一个归属小节"、"双语平权"、"文档里的路径必须真实存在" |
| 禁区 | 不能碰什么 | 5 条，含"不新增第二份规则清单"、"不改旧号 `R0xx`"、"不默认读者的 agent 工具" |
| 已知的坑 | 每踩一次加一条 | 6 条，含"锚点不可链"、"`guide/` 不许开子目录"、"索引与条目小节是三处受控双写" |
| 拿不准时 | 停止条件 | "停下来问，并列 2–3 个选项与取舍" |

可直接抄的空白骨架：[templates/AGENTS.md.tmpl](../../../templates/AGENTS.md.tmpl)（实测 8 段、51 行）。

`guide/03 §2` 那句判断值得单独抄出来：**agent 文档里最贵的不是知识，是停止条件。**
`cli/cli` 的 `AGENTS.md` 里最显眼的不是代码规范，而是三条边界——不许给未经邀请的上游 PR 做准备
（要 `help wanted` + 明确验收标准）、安全问题不进公开 issue / PR / commit、
**"实现完了"不等于可以 commit、push、publish**。三条都不是"怎么写代码"，都是"什么时候该停"。

## 分流表：什么进根文件，什么搬走

`writing/agents-md-length` 的「怎么做」只有一句"移到 `.claude/rules/`（带 paths）、移到 skill"。
判断标准在 [guide/04 §1.3](../../../guide/04-Agent怎么用.zh-CN.md)：**每次都要知道 → 根文件；做某件事时才需要 → skill。**

| 这段内容 | 该放哪 | 为什么 | 加载机制 |
|---|---|---|---|
| 跑测试 / 构建 / lint 的命令 | 根文件 | 每次都要 | 启动即加载 |
| 目录地图、硬约定、已知的坑 | 根文件 | 每次都要 | 启动即加载 |
| 某个包 / 子系统的专属规则 | 子目录 `AGENTS.md`，或 `.claude/rules/*.md` + `paths:` | 只有读到那里才需要 | 根文件启动时加载，子目录**按需**加载；不想要的用 `claudeMdExcludes` 排除 |
| 发布、迁移这类多步流程 | skill | 只在被调用时加载，不占日常上下文 | 位置约定见 [hooks 与 skill 资产规则](../agent-config/hooks-skills.md) |
| 只对某一个工具有意义的一句 | 工具的适配层文件（如 `CLAUDE.md`） | 别的工具读到会困惑 | 判据是"这条对别的工具没意义" |
| "这个仓库有没有 `AGENTS.md`" | 不在本页 | 那是存在性 | [根目录规则](../documents/essentials.md) |
| 为什么当初选了 A 不选 B | ADR | 未来的维护者读，agent 不必每次读 | [ADR 规则](adr.md) |

反例 → 正例（[guide/03 §2](../../../guide/03-文档该怎么写.zh-CN.md) 原表）：

| 反例 | 问题 | 正例 |
|---|---|---|
| 把 README 复制一遍 | 浪费预算，且会不同步 | 第一行写"人类入口见 README" |
| "遵循项目既有风格" | 无判据 | "新增文件用 kebab-case，导出统一放 index.ts" |
| 列了 12 条代码规范 | 占了 1/3 预算，几乎不被用到 | 压成 3 条真正会踩的 |
| "不要破坏现有功能" | 无法执行 | "改 `src/api/` 后必须跑 `pnpm test:e2e`" |
| 写"如何发布"的 8 个步骤 | 属于流程，不是事实 | 移进 `.claude/skills/release/SKILL.md` |

**常见误判一：把 200 行当达标线。** 超了不是"内容多"，是"位置错"。
**常见误判二：以为越短越好。** vscode 那 8 行成立的前提是"真正的细则在别处、且指针是对的"；
指针指错，短就是空的。分层的前提是**按需加载真的生效**，否则只是把一份长文档切成三份没人读的碎片。

## 命令表与禁区：两节必须能被机器对上

**命令表是最高价值的一节。** 理由不是"方便"，而是命令是 agent **最容易被旧记忆污染**的信息：
它见过太多 `npm test`，就会假设你也是。所以这一节的身份是"唯一权威，勿自行发明"，不是"参考"。

本仓库提供了一个极端但有用的活样本——**一个没有任何可执行命令的仓库，仍然写了这一节**
（原文见 [AGENTS.md](../../../AGENTS.md)「命令」一节）：

> **本库没有任何可执行命令**——没有检查器、没有生成器、没有安装步骤。
> 不要为了"跑一下规范"去找命令，找不到是对的。

这一节的价值恰恰在于：**否定的命令也要写**。不写，agent 会自己找一个看起来合理的（`npm test`、`make lint`），
然后花时间证明它不存在。表格三列是 `用途 | 怎么做 | 备注`，把"没有"当成一种答案填进去。
判据（guide/03 §2 判据第 1 条）：**把命令表里的每条命令照抄执行，能不能跑通？** 跑不通就说明它已经腐烂。

禁区那一节要能被对上，才对得上机器。[guide/04 §3](../../../guide/04-Agent怎么用.zh-CN.md) 给的三行：

| 只写在 `AGENTS.md` 里 | 升级为确定性机制 |
|---|---|
| 不要读 `.env` | `permissions.deny: ["Read(./.env)"]` |
| 改完必须格式化 | `PostToolUse` hook 直接跑 formatter |
| 不要动 `migrations/` | `Edit(./migrations/**)` deny，或 hook 里 `exit 2` |

所以「怎么做」里那句"由 hooks 强制"不是修饰语，是**验收方式**：一条禁区如果既没有 deny、
也没有 hook 或 CI 检查，它就只是一句希望。配置本身归 [权限与 hook 门禁规则](../agent-config/permissions.md)；
真正的硬闸门归 [分支保护规则](../settings/branch-protection.md)——那里有本库被自己的开关锁死一次的复盘。

禁区还要写"为什么"和"怎么办"：只写"禁止修改 X"，agent 会绕；写"X 由人工 PR 处理，因为…"，它才会停。
本仓库「已知的坑」里那条就是这种写法——它给了原因（ruleset 存的是**字符串**）和顺序
（先加新名字的 job → 改 ruleset → 下一个 PR 再删旧 job）。

## 路径与语言：成本最低的两条

**路径。** 文档腐烂最常见形态就是重构后路径全失效，agent 照着不存在的路径干活。
本库对这条的支持比多数仓库强，也比多数仓库**更不完整**——这个反差值得写下来：

| 这件事 | 本库 CI 查不查 | 依据 |
|---|---|---|
| 相对链接指向的文件在不在 | **查**。`链接检查` job 用 lychee `--offline`，glob 覆盖 `./**/*.md` 与 `./**/*.tmpl` | [.github/workflows/docs.yml](../../../.github/workflows/docs.yml) |
| 链接里的 `#锚点` 对不对 | **不查**。参数里没有 `--include-fragments`，而 lychee 默认不校验 fragment | [ADR-0013](../../../docs/adr/0013-rules-by-domain.md) 决策 5 |
| `guide/` 子目录里的文件 | **不查**。`双语配对` 用的是平铺 `for f in guide/*.md`，不递归，子目录静默漏检 | 同上 workflow |

也就是说：这条条目的「怎么做」（"在 CI 里常驻本检查"）在本库**只做到了一半**——文件级链接有闸门，锚点没有。
所以本库定的规矩是**一律链到文件，不链到小节**：代价是多一次 Ctrl-F，换来"锚点不会悄悄烂掉"。
写文档时把它当硬约束——`xxx.md#小节` 写错了 CI 永远不红，那是一种**查不出来的腐烂**，
而这个库的主题就是防腐。顺带一条实测：本次重写时检查本仓库 `AGENTS.md` 的 14 条相对链接，**0 条失效**；
这条判据可判定、成本是一次 CI。

**语言。** 在靠前位置声明一次。不声明，agent 跟着代码注释或它上次的输出来走，
同一仓库最后出现两种语言，reviewer 每次都要纠正。可直接粘的片段：
[templates/prompt-locale.md.tmpl](../../../templates/prompt-locale.md.tmpl)。

"不翻译"的清单要写死——规则 ID、文件路径、命令、代码标识符、模板占位符；否则第一次翻译就把清单条目译丢。
本仓库「语言约定」就是这么写的，并且多了一层本库特有的约定：**默认文件英文、中文镜像 `*.zh-CN.md`、两版平权**
（[ADR-0008](../../../docs/adr/0008-bilingual-equal-status.md)）。

一处值得点破的偏差：判据句和模板片段都说"译文与原文冲突时**以原文为准**"，
而本库 `AGENTS.md` 与 [ADR-0008](../../../docs/adr/0008-bilingual-equal-status.md) 结论第 3 条写的是
"**以证据裁定，不以语言裁定**"。两者不矛盾：前者是默认（别自己悄悄改判据），
后者是升级条件（两版都可能错时，看 `docs/evidence/` 的数据或跑一遍命令，谁写错改谁——事实不分语言）。
只抄前一句的人会丢掉后半句。

为什么停在 `may`：**没有真实事故支撑**。采样里只有 `kubernetes/kubernetes` 写了沟通偏好，
没有任何证据表明缺了它就会出事——[spec/README.md](../../README.md) 专门用一节讲这条，
就是为了防止它被误读成"规范要管你用什么语言"。**它管的是有没有声明，不是声明成什么语言。**

## 条目

### AGENTS.md 不超过 200 行

`writing/agents-md-length` · L3 · should · 旧 `R030`

**为什么。** 每次会话都全文加载；超过 200 行内容变贵且遵守率下降。

**怎么做。** 把模块级规则移到 .claude/rules/（带 paths），把多步流程移到 skill。

### AGENTS.md 含“命令”一节

`writing/agents-md-commands` · L3 · should · 旧 `R031`

**为什么。** 命令是 agent 最依赖、最容易被旧记忆污染的信息，必须有唯一权威。

**怎么做。** 在 AGENTS.md 加“## 命令（唯一权威）”，列安装/开发/测试/检查。

### AGENTS.md 含“禁区”一节

`writing/agents-md-boundaries` · L3 · should · 旧 `R032`

**为什么。** 禁区不写清楚，agent 只能靠猜边界；写清楚后还能被 hooks/CI 对应上。

**怎么做。** 加“## 禁区（由 hooks 强制）”，列受保护路径与破坏性命令。

### AGENTS.md 引用的路径都存在

`writing/agents-md-paths` · L3 · should · 旧 `R037`

**为什么。** 文档腐烂最常见形态：重构后路径全失效，agent 照着不存在的路径干活。

**怎么做。** 修正或删除失效引用；在 CI 里常驻本检查。

### AGENTS.md 声明输出语言

`writing/agents-md-language` · L3 · may · 旧 `R042`

**为什么。** agent 的语言默认跟着代码注释或它上次的输出来走，没人声明就会在同一仓库里出现两种语言，reviewer 反复纠正。声明一次的成本最低。**没有真实事故支撑，故停在 may。**

**怎么做。** 在 AGENTS.md 靠前位置加「语言约定」：使用语言、不翻译清单（规则 ID / 路径 / 命令 / 代码标识符）、译文与原文冲突时以原文为准。可直接粘的片段见 `templates/prompt-locale.md.tmpl`。

## 相关

- [ADR 规则](adr.md) — "为什么不是另一种做法"写在那里，不占这 200 行
- [PR 模板的自检清单](pr-template.md) — 禁区与硬约定在评审层的落点
- [声明不可信输入](untrusted-inputs.md) — `AGENTS.md` 里最晚补上的一节
- [根目录规则](../documents/essentials.md) — `AGENTS.md` 的存在性
- [权限与 hook 门禁规则](../agent-config/permissions.md) — 禁区的确定性执行端
- [hooks 与 skill 资产规则](../agent-config/hooks-skills.md) — 搬出去的"多步流程"放哪
- [目录树与文档位置规则](../layout/docs-tree.md) — `.claude/rules/` 与 skill 的位置约定
- [提交规则](../governance/commits.md) — 仓库自己的提交约定写进 `AGENTS.md`
- [分支保护规则](../settings/branch-protection.md) — 提示与闸门的分工
- [guide/03 · 文档该怎么写](../../../guide/03-文档该怎么写.zh-CN.md) — 八段骨架与判据的原处
