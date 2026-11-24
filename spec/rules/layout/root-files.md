# 根目录规则

> 板块 `layout` · 本页承载 3 条条目：`layout/gitignore`（L0 · must · 旧 `R003`）·
> `layout/editorconfig`（L1 · may · 旧 `R015`）· `layout/gitattributes`（L1 · may · 旧 `R016`）
> 讲解与采样依据见 [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md)。
> 通用术语与具体文件名的对应见 [机制对照表](../../mechanism-map.md)（附录，非规范）。

## 一句话

根目录那三个点开头的文件不是工程惯例，是**三段互不重叠的链路**：`.gitignore` 决定什么东西进不了仓库，
`.editorconfig` 决定编辑器往磁盘写什么字节，`.gitattributes` 决定仓库里存什么字节、diff 怎么算。
少一个就有一段没人管；而这三段里只有 `.gitignore` 那段**漏了收不回来**——所以它是 L0 `must`，另两个只到 `may`。

## 根目录是入口区，不是仓库

[guide/02](../../../guide/02-目录结构.zh-CN.md) §0 的判据是一句话：**根目录里每个文件，都能说出"谁会在什么情况下点开它"吗？**
说不出来的就是错位。本页三条恰好属于"说不出用途、但必须存在"的那一类——**它们的读者不是人，是工具。**

同章的三色清单：

| 颜色 | 内容 | 本页负责的部分 |
|---|---|---|
| **必须有** | `README.md`、`LICENSE`、`.gitignore`、`AGENTS.md` | `.gitignore`（工具默认读根） |
| **可以有** | `.github/`、`CONTRIBUTING.md`、`SECURITY.md`、`CHANGELOG.md`、`CODE_OF_CONDUCT.md`、构建清单、`Makefile`、`.editorconfig`、`.gitattributes`、工具专属指令文件、`.mcp.json` | `.editorconfig`、`.gitattributes` |
| **不要放** | 架构文档与长指南（→ `docs/`）、会议记录与临时笔记、生成物与日志（→ `.gitignore` 掉）、成堆脚本（→ `scripts/`）、各环境配置副本、一个只装一个文件的目录 | 最后一列的"生成物"就是 `layout/gitignore` 的落点 |

**"根目录越少越好"是误判。** 同章 §1 的实测里，`sindresorhus/got` 根目录只有几个文件，
`microsoft/vscode` 有几十个——密度取决于构建方式（有没有 monorepo 工具、有没有大量配置），不取决于审美。
规范因此只判"该在根的三个点文件在不在"，不判根目录看起来清爽不清爽。

## 三个文件各管一段

| 文件 | 谁读它 | 管什么 | 不管什么 | 缺了会怎样 | 本页级别 |
|---|---|---|---|---|---|
| `.gitignore` | git，以及所有默认调 git 的工具（含 agent） | 哪些路径**不进未跟踪集合** | 已经跟踪的文件；仓库外的东西 | 构建产物与密钥迟早进历史，清理要改写历史 | L0 · `must` |
| `.editorconfig` | 编辑器与 IDE，以及尊重它的格式化工具 | 工作区文件的缩进、行尾、字符集、末行换行 | 仓库里存什么、diff 怎么算 | 每个人写出的字节不一样，diff 里全是格式噪音 | L1 · `may` |
| `.gitattributes` | git 自己 | 归一化（`text` / `eol`）、二进制判定（`binary`）、属性标记（`linguist-*`） | 编辑器行为、什么该被忽略 | 跨平台整文件 diff；图片被当文本转换而损坏 | L1 · `may` |

## 行尾这件事，两个文件是一个机制的两半

本仓库两份文件都在，可以直接当例子：

- [.editorconfig](../../../.editorconfig) 的 `[*]` 段写了 `charset = utf-8`、`end_of_line = lf`、
  `insert_final_newline = true`，并给 `[*.md]` 单独关掉 `trim_trailing_whitespace`——
  因为 Markdown 里**行尾两个空格是硬换行**，全局 trim 会吃掉语义。
- [.gitattributes](../../../.gitattributes) 第 2 行 `* text=auto eol=lf`，再给 `*.md` `*.json` `*.yml`
  `*.yaml` `*.sh` 显式 `text eol=lf`，给 `*.png` `*.jpg` `*.gif` `*.ico` `*.zip` `*.gz` 标 `binary`。

两半各缺一半的后果不同，而且都不是洁癖问题：

| 只有 `.editorconfig` | 只有 `.gitattributes` |
|---|---|
| 没装插件的编辑器（和多数 agent 的写文件路径）照样写 CRLF；文本能被 git 归一化救回来，**没标 `binary` 的图片会被当文本转换** | 仓库里存的是 LF，但工作区文件可能仍是 CRLF；agent 读进来再原样写回，就产生整文件 diff |

`.gitattributes` 还兼第二份工作，本仓库那份的注释写得很直白：不标 `linguist-documentation`，
`templates/` 下的 `*.tmpl` 会被语言统计认成 Go Template，仓库首页就显示成"Go Template"项目。
**这与行尾无关，但同属"声明文件属性"，所以只有 `.gitattributes` 能干。**

## 为什么只有 `.gitignore` 是 must

看失效能不能收回来：

| 失效 | 怎么被发现 | 修复成本 |
|---|---|---|
| 没有 `.editorconfig` | 某次 PR 里出现整文件空白 diff | 补文件 + 一次格式化提交，历史不用动 |
| 没有 `.gitattributes` | 跨平台整文件 diff / 二进制损坏 | 补文件；已损坏的二进制重新提交一次，历史仍可保留 |
| 没有 `.gitignore` | 构建产物或 `.env` 已经躺在历史里 | **改写历史 + force push**，而 `main` 通常禁止 force push（[分支保护规则](../settings/branch-protection.md) 的 `non_fast_forward`） |

[spec/README.md](../../README.md) 的「三档严重度」把 `must` 定义为"缺了就是硬伤，会在几周内咬人"。
`.gitignore` 缺失正是这种：它不是少了个方便，而是**默认配置下迟早发生、且不可逆**。
`.editorconfig` 与 `.gitattributes` 的缺失同样会烦人，但**永远可以在下一个 PR 里补上而不碰历史**，所以停在 `may`。

**一个文件，两种职责，分属两页。** `.gitignore` 的通用忽略（依赖目录、构建产物、`.env*`）判据在本页
`layout/gitignore`；**排除个人 agent 配置**（个人覆盖文件，具体文件名见
[机制对照表](../../mechanism-map.md)）是另一条判据，
归 [agent 配置文件的提交纪律](agent-files.md) 的 `layout/ignore-agent-personal`。
本仓库 [.gitignore](../../../.gitignore) 开头几行是后者，其余是编辑器/系统/临时文件；
**前者那三项（依赖目录、构建产物、`.env*`）是本页判据对"有代码的仓库"的要求**——本库是纯文档库，
没有依赖目录，所以没列，照抄到真实项目时要补上。同一个文件，两条判据各查各的，别写重。

## 常见误判

| 说法 | 为什么是误判 | 怎么办 |
|---|---|---|
| "有 `.gitignore` 了，`.env` 就进不来了" | `.gitignore` 只作用于**未跟踪**文件；已经跟踪的照旧提交 | `git rm --cached <path>` 再验命中，见 [agent-files.md](agent-files.md) |
| "`.gitignore` 是隐私机制" | 它管"要不要跟踪"，不管"谁能看"；密钥的正确归宿是环境变量与最小权限凭证 | 凭证问题看 [归属与凭证规则](../governance/ownership.md) |
| "行尾交给编辑器就行" | 编辑器只覆盖装了它的人；agent 与 CI 的写文件路径不一定经过 `.editorconfig` 生态 | 两半都要：`.editorconfig` + `.gitattributes` |
| "`Doc/` 不合规，改名成 `docs/`" | 改名让所有外部链接失效，收益远小于成本 | 新建用 `docs/`，存量不动（见 [docs-tree.md](docs-tree.md)） |
| "根目录文件越少越专业" | 实测里根目录密度取决于构建方式，不是审美指标 | 只查"该在根的在不在、不该在根的有没有下沉" |

## 条目

### 存在 .gitignore

`layout/gitignore` · L0 · must · 旧 `R003`

**为什么。** 没有 .gitignore 的仓库迟早把构建产物和密钥提交进来。

**怎么做。** 加 .gitignore，至少覆盖依赖目录、构建产物、.env*。

### 存在 .editorconfig

`layout/editorconfig` · L1 · may · 旧 `R015`

**为什么。** 跨编辑器统一缩进与行尾，减少 agent 与人的格式噪音。

**怎么做。** 加 .editorconfig，声明缩进、行尾、字符集。

### 存在 .gitattributes（Windows 协作必查）

`layout/gitattributes` · L1 · may · 旧 `R016`

**为什么。** 不处理行尾与二进制/LFS，跨平台协作会产生整文件 diff 与损坏的二进制。

**怎么做。** 加 .gitattributes：* text=auto eol=lf，图片/字体标 binary。

## 相关

- [docs/ 与跨工具资产位置](docs-tree.md) — 根只留入口，其余下沉到哪儿
- [agent 配置文件的提交纪律](agent-files.md) — 同一个 `.gitignore` 的第二种职责：排除个人 agent 配置
- [分支保护规则](../settings/branch-protection.md) — `non_fast_forward` 让"改写历史清泄露"这条路走不通
- [规则索引](../README.md) — 本板块 8 条的档位与判据一览
- [spec/README.md](../../README.md) — 三档严重度与符合性声明
- [机制对照表](../../mechanism-map.md) — 通用术语 ↔ 具体文件名（附录，非规范）
- [guide/02 · 目录结构](../../../guide/02-目录结构.zh-CN.md) — 三色清单与十仓实测
- [十仓形态采样](../../../docs/evidence/2026-11-17-repo-sampling.md) — 根目录形态与 `.github/` 内容
