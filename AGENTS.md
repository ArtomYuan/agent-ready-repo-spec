# AGENTS.md

> 本文件是 agent 处理这个仓库时的唯一事实源。人类入口见 [README.md](README.md)，规范正文见 [spec/README.md](spec/README.md)。

## 这个仓库是什么

一个**纯规范文档库**：讲清楚"一个 agent 参与的 GitHub 仓库该长什么样、文档该怎么写、agent 参与时该怎么管理"。

- **不含规则引擎**：没有检查器、没有生成器、没有包管理器清单。唯一的自动化是平台自带的两个必需检查（链接检查 / 双语配对，见 [`.github/workflows/docs.yml`](.github/workflows/docs.yml)），它们只校验文档自身的一致性，**不校验规则**。见 [ADR-0009](docs/adr/0009-spec-only-no-tooling.md)。
- **不绑定任何语言或工具**：不默认读者用 Claude、Codex 或 Cursor，也不要求读者装任何运行时。
- 使用者做的是：读文档 → 复制模板 → 对着 [spec/rules/README.md](spec/rules/README.md) 逐条比对。

## 语言约定

- **仓库里的文件**：默认文件（`*.md`）是**英文**，中文镜像是 `*.zh-CN.md`，两版平权（[ADR-0008](docs/adr/0008-bilingual-equal-status.md)）。
- **协作过程**：PR 描述、commit message、ADR、`docs/evidence/`、issue 讨论用**中文**。
- 目前只有中文的部分：`spec/`、`docs/`、`CONTRIBUTING.md`、`CHANGELOG.md`、`.github/` 下的模板、本文件。
- **不翻译**：规则 ID（`板块/主题` 与旧号 `R0xx`）、文件路径、命令、模板占位符、GitHub 设置名（`required_status_checks` 这类）。
- 译文与原文冲突时**以证据裁定，不以语言裁定**（ADR-0008 第 3 条）。

## 命令（唯一权威，勿自行发明）

**本库没有任何可执行命令**——没有检查器、没有生成器、没有安装步骤（[ADR-0009](docs/adr/0009-spec-only-no-tooling.md)）。
不要为了"跑一下规范"去找命令，找不到是对的。

| 用途 | 怎么做 | 备注 |
|---|---|---|
| 自查一个仓库 | 对着 [spec/rules/README.md](spec/rules/README.md) 逐条比对 | 人或 agent 来做，顺序见 [spec/agent-playbook.md](spec/agent-playbook.md) §2 |
| 改一条规则 | 在 `spec/rules/<板块>/` 里找到承载它的那篇，改「条目」里那一节，**同时**改 `spec/rules/README.md` 那一行 | 判据正文只在那一节，索引只导航；判据变严要升 `specVersion` |
| 本地验链接 | 无。CI 用 lychee `--offline` 跑 | 想本地复现，任何语言写几行都行，本库不提供 |
| 本地验双语 | 无。CI 比对中英标题数 | 同上 |
| 唯一自动化 | `.github/workflows/docs.yml` 的两个必需检查 | **链接检查** · **双语配对**，只校验文档自身 |

## 目录地图

- `guide/` — 指导正文，八章 + 索引。**每章都有中英两版**（`xxx.md` 与 `xxx.zh-CN.md`）。
- `spec/` — 规范骨架：`README.md`（怎么读、级别、**符合性声明**、版本与编号策略）、`agent-playbook.md`（agent 的阅读顺序）。
- `spec/rules/` — **55 条规则**，按 8 个板块分目录：
  `adoption/` `documents/` `layout/` `writing/` `agent-config/` `governance/` `release/` `settings/`。
  板块内**按话题成篇**，共 **22 篇**（如 `release/` = `version.md` / `content.md` / `artifact.md`；
  `settings/` = `branch-protection.md` / `ci.md`），**一条规则是某篇文档「条目」小节里的一节**。
  `rules/README.md` 是索引（一行一条：旧号 · ID · 级别 · 判据 · 承载页链接），**不含判据正文**。
  **ID 不等于路径**：`release/moving-tags` 的归属地是 `release/artifact.md`。
- `templates/` — 复制到目标仓库的模板，含 `{{PLACEHOLDER}}`。
- `docs/` — 设计说明与 ADR（`docs/adr/`）、实测证据（`docs/evidence/`）、文档地图（`docs/index.md`）。
- `.github/` — 平台文件：PR 模板、Issue 模板、CODEOWNERS。

## 硬约定

- **一条规则只有一个归属小节**：某篇主题文档「条目」里的那一节，小节元数据行写着它的 ID（`板块/主题`）。
  改判据只改那一节；`rules/README.md` 的对应行只做导航，**别处不得复制判据**。
  不要再引入第二份清单（JSON、生成物、脚本）——ADR-0009。
- **双语平权**（[ADR-0008](docs/adr/0008-bilingual-equal-status.md)）：`xxx.md` 与 `xxx.zh-CN.md` 地位相同，
  改内容必须在**同一个 PR** 内同步两边；只改一侧视为未完成。冲突时以**证据**裁定，不以语言裁定。
- **不翻译**：规则 ID（`板块/主题` 与旧号 `R0xx`）、文件路径、命令、模板占位符。
- **文档里的路径必须真实存在**——读者会顺着点。
- **不要引入可执行物或规则校验**：不加 `.ps1`/`.js`/`.py`、不加 `package.json`/`requirements.txt`、不加**校验规则（checklist）** 的 workflow。
  `docs.yml` 只校验文档自身（链接、双语配对），不在禁区之列。需要自动化的人应当另建仓库消费本清单。
- 提交信息用 Conventional Commits，scope 取 `guide` / `spec` / `templates` / `docs`。

## 禁区

- 不新增第二份规则清单，也不在归属小节之外复述判据（会立刻产生漂移）。
- 不改旧号 `R0xx`，不改板块名。旧号永不复用；板块名编码在每条 ID 里。
- 不默认读者的 agent 工具：需要提到具体工具时，写成条件式（"若你用 Claude Code…"）。
- 不在文档里写"必须装 X"——除非那是被指导仓库自己的选择。
- 不提交个人配置（`.env`、本地路径、私有凭证）。

## 已知的坑

- **双语文档最容易漂移**：改一侧忘了另一侧。提交前用 `grep` 对照两版的小标题数量。
- **相对路径在多级目录里容易写错**：`guide/*.md` 引用 `docs/` 要写 `../docs/...`。
- **索引与条目小节是三处受控双写**：`rules/README.md` 的「判据」列 = 小节标题，「级别」列 = 小节元数据行，
  档位 = 索引分节 vs 元数据行。改一条规则时**两处一起改**，逐字核对（本库不提供检查器）。
- **锚点不可链**：一个板块内多条规则共用一篇文档，但索引只链到**文件**，不链 `#小节`
  （lychee 没开 `--include-fragments`，锚点错了 CI 不红）。定位靠在小节里搜 ID。
- **`guide/` 不许开子目录**：`双语配对` 用的是 `for f in guide/*.md`，**平铺 glob 不递归**，
  子目录里的文件会静默不被检查。规则拆目录只发生在 `spec/rules/`。
- **删过的东西还会有引用**：本仓库曾删掉检查器与 `.claude/`（ADR-0009），历史的 ADR 里刻意保留旧命名，
  新文档不要再引用已删除的路径。

## 提交与 PR

- 分支：`feat/<slug>`、`fix/<slug>`、`docs/<slug>`、`chore/<slug>`
- **main 受保护**：所有变更都走 PR，直推会被拒绝（[ADR-0004](docs/adr/0004-all-changes-via-pr.md)）。
- PR 描述用 [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)，四段：改了什么 / 下一步 / 非目标 / 怎么验证的。

## main 的保护配置（动 CI 之前先看这张表）

| 规则 | 值 |
|---|---|
| `deletion` | 禁止删除 main |
| `non_fast_forward` | 禁止 force push |
| `required_status_checks` | **链接检查** · **双语配对** —— 名字必须与 `.github/workflows/docs.yml` 的 job 名**逐字一致** |
| `pull_request` | 必须 PR；1 个人工批准；批准后再推需重批；只允许 squash |
| `required_linear_history` | 只允许线性历史 |

**改 job 名之前必须看这里**：ruleset 存的是**字符串**，删掉或改名，那一项就永远
`Expected — Waiting for status to be reported`，main 从此不可合并。
正确顺序是先加新名 job → 改 ruleset → 下个 PR 删旧 job。详见 [guide/05 附录](guide/05-Agent参与怎么管理.md)；真实事故复盘见 [ADR-0010](docs/adr/0010-required-checks-self-lock.md)。

`双语配对` 校验两件事：中英两版**文件成对**，且**标题数一致**（后者是上面「双语平权」那条硬约定的唯一执行点）。

## 拿不准时

停下来问，并列 2–3 个选项与取舍。**不要**为了"看起来更专业"而给文档库加工具——那正是 ADR-0009 推翻的做法。
