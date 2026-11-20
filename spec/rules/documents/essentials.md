# 三份基础文件规则

> 板块 `documents` · 本页承载 4 条条目：`documents/readme`（L0 · must · 旧 `R001`）·
> `documents/agents-md`（L0 · must · 旧 `R002`）· `documents/license`（L0 · must · 旧 `R004`）·
> `documents/license-not-placeholder`（L2 · may · 旧 `R027`）
> 讲解与采样依据见 [guide/01 · 该有什么文档](../../../guide/01-该有什么文档.zh-CN.md)。

## 一句话

README、AGENTS.md、LICENSE 是同一件事的三个面：**陌生人、agent、法律上的人，能不能不问你就把仓库接手下去**。
三份文件都是 L0 `must`；`license-not-placeholder` 单独是 L2 `may`，因为它管更阴的一档——**文件在，内容却是空的**。
这一篇的重点就在这里：存在不等于生效。

## 三个读者，三份文件

`README.md` 写给**30 秒内决定"要不要用"的陌生人**，要给他定位 + 跑得起来的最小命令 + 入口链接；
`AGENTS.md` 写给**每次会话全文加载它的 agent**，要给它命令、目录地图、硬约定、禁区、已知的坑；
`LICENSE` 写给**打算合法使用的人（和他的法务）**，要给他可引用的协议名 + 真实著作权人与年份。

十仓实测：README **10/10**、LICENSE **10/10**、`AGENTS.md` **6/10**、`CLAUDE.md` **1/10**（唯一那个是 Anthropic
自家仓库），见 [十仓采样](../../../docs/evidence/2026-11-17-repo-sampling.md)（样本非随机、偏开源大仓）。
**README 与 LICENSE 是行业基线**，所以它们只该出现在"做得够不够"的讨论里。

## README：判据是 30 秒，不是完整

判据就是 [guide/03 §11](../../../guide/03-文档该怎么写.zh-CN.md) 自检第一条：**前 20 行能不能让陌生人判断要不要用**。
长度预算 ≤100 行，超了就往 `docs/` 拆。反例：三段背景铺垫、第四屏才出现"怎么用"；快速开始写"安装依赖后运行"。
正例：第一句就是"这是什么"（本库 `README.md` 第 3 行即定位句），快速开始给一条真命令——并记住它**最后一次实际跑通**是什么时候。

**位置陷阱**：GitHub 取 `.github/` > 根 > `docs/` 的**第一个** README。在 `docs/` 放了 README 不等于首页有内容——
`.github/` 下若也有一个，首页显示的是后者。

## AGENTS.md 与 README 的分工

同一个事实写两份就一定漂移（guide/03"一份内容一个位置"）。按**读者**切：给人看的（怎么装、怎么跑起来、协议与贡献入口）
进 `README.md`；给 agent 看的（**仓库内命令的唯一权威**、禁区、停止条件、已知的坑）进 `AGENTS.md`——
README 里的命令会随重构过期，agent 照着过期命令干活。

实测从 8 行 / 0.5 KB（`microsoft/vscode` 纯路由）到 50 KB（`modelcontextprotocol/servers` 大全型，
只在单团队、约定集中且能持续维护时成立）都有，**没有统一长度**，见
[agent 指令文件采样](../../../docs/evidence/2026-11-18-agent-docs-sampling.md)。L0 只判**存在**；长度、命令节、
禁区节、路径是否还存在，是 [AGENTS.md 写法规则](../writing/agents-md.md) 那一组条目。

## LICENSE：存在 ≠ 有效

同一份文件的两级判据，中间差三档：

| 状态 | 后果 | 怎么判（照做一遍就能验） |
|---|---|---|
| 没有 LICENSE 文件 | 默认保留全部权利，别人无法合法使用（R004） | 根目录有没有 `LICENSE` / `LICENSE.md` / `COPYING` |
| 有文件，但是占位文本 | **在法律上等于没有协议**（R027）：它没指明"谁在授权" | 打开看第三行：年份是不是真的、著作权人是不是你 |
| 有文件且填了 | 协议生效 | README 指到它，两处协议名一致；本库为 `Copyright (c) 2026 agent-ready-repo-spec contributors` |

为什么"存在但是占位符"值得单独立一条：**它骗过所有只看"有没有"的检查**——文件在、协议名对、行数正常，
只有第三行是错的。本库对这一类失败有书面立场：[ADR-0002](../../../docs/adr/0002-checker-is-read-only.md)
因此拒绝 `--fix` 自动补文件（"会生成一堆占位内容，且占位内容本身会被判为未完成"）；
[SECURITY.md](../../../SECURITY.md) 把"模板里的占位符没填"列为真实风险面——它产出的是一道
**看着已经打开、其实没有**的闸门；本库 `.github/ISSUE_TEMPLATE/bug.yml` 里那个占位的 `specVersion`
被 [CONTRIBUTING.md](../../../CONTRIBUTING.md) 列进每次发版必改的三处声明，原话是"漏一处，首页就开始说谎"。
R027 只到 `may` 也是刻意的：它不阻断你达到 L0，而填占位符的成本是 30 秒。

## 常见误判

| 误判 | 为什么错 |
|---|---|
| "有 `CLAUDE.md` 就够了" | 跨工具的公共项是 `AGENTS.md`；`CLAUDE.md` 实测 1/10，还是 Anthropic 自家仓库 |
| "README 里写了 MIT，就等于有协议" | 一句话不是协议文本，GitHub 认的是根目录那个文件 |

## 条目

### 存在 README

`documents/readme` · L0 · must · 旧 `R001`

**为什么。** GitHub 按 .github/ > 根 > docs/ 的顺序取第一个 README 作为仓库首页；没有它，仓库等于不可评估。

**怎么做。** 写 README.md：一句话定位 + 30 秒能跑起来的最小命令 + 入口链接。

### 根目录存在 AGENTS.md

`documents/agents-md` · L0 · must · 旧 `R002`

**为什么。** AGENTS.md 是跨工具的 agent 唯一事实源；Claude Code 在无 CLAUDE.md 时默认直接读它。

**怎么做。** 在根目录建 AGENTS.md。八段骨架见 [guide/03 §2](../../../guide/03-文档该怎么写.zh-CN.md)：项目是什么 / 语言约定 / 命令 / 目录地图 / 硬约定 / 禁区 / 已知的坑 / 拿不准时。可直接粘：[templates/AGENTS.md.tmpl](../../../templates/AGENTS.md.tmpl)。

### 存在 LICENSE

`documents/license` · L0 · must · 旧 `R004`

**为什么。** 无协议等于默认保留全部权利，别人无法合法使用。

**怎么做。** 选一个 OSI 协议（MIT / Apache-2.0）放进根目录，并写进 README。

### LICENSE 不是占位文本

`documents/license-not-placeholder` · L2 · may · 旧 `R027`

**为什么。** 占位 LICENSE 在法律上等于没有协议。

**怎么做。** 填入真实年份与著作权人。

## 相关

- [协作面四件套规则](collaboration.md) · [信任与举报规则](trust.md)
- [AGENTS.md 写法规则](../writing/agents-md.md) — 长度、命令节、禁区节、引用路径
- [根文件规则](../layout/root-files.md) — `.gitignore` 等根目录文件
- [guide/01 · 该有什么文档](../../../guide/01-该有什么文档.zh-CN.md) — 三档清单与十仓实测
