# AGENTS.md

> 本文件是 agent 处理这个仓库时的唯一事实源。人类入口见 [README.md](README.md)，规范正文见 [spec/README.md](spec/README.md)。

## 这个仓库是什么

一个**纯规范文档库**：讲清楚"一个 agent 参与的 GitHub 仓库该长什么样、文档该怎么写、agent 参与时该怎么管理"。

- **不含规则引擎**：没有检查器、没有生成器、没有包管理器清单。唯一的自动化是平台自带的两个必需检查（链接检查 / 双语配对，见 [`.github/workflows/docs.yml`](.github/workflows/docs.yml)），它们只校验文档自身的一致性，**不校验规则**。见 [ADR-0009](docs/adr/0009-spec-only-no-tooling.md)。
- **不绑定任何语言或工具**：不默认读者用 Claude、Codex 或 Cursor，也不要求读者装任何运行时。
- 使用者做的是：读文档 → 复制模板 → 对着 [spec/checklist.md](spec/checklist.md) 逐条比对。

## 目录地图

- `guide/` — 指导正文，八章 + 索引。**每章都有中英两版**（`xxx.md` 与 `xxx.zh-CN.md`）。
- `spec/` — 规范骨架：`README.md`（怎么读、级别、版本策略）、`checklist.md`（37 条唯一事实源）、`agent-playbook.md`（agent 的阅读顺序）。
- `templates/` — 复制到目标仓库的模板，含 `{{PLACEHOLDER}}`。
- `docs/` — 设计说明与 ADR（`docs/adr/`）、实测证据（`docs/evidence/`）、文档地图（`docs/index.md`）。
- `.github/` — 平台文件：PR 模板、Issue 模板、CODEOWNERS。

## 硬约定

- **`spec/checklist.md` 是规则唯一事实源**。改规则只改它；不要再引入第二份（JSON、生成物、脚本）。
- **双语平权**（[ADR-0008](docs/adr/0008-bilingual-equal-status.md)）：`xxx.md` 与 `xxx.zh-CN.md` 地位相同，
  改内容必须在**同一个 PR** 内同步两边；只改一侧视为未完成。冲突时以**证据**裁定，不以语言裁定。
- **不翻译**：规则 ID（`R0xx`）、文件路径、命令、模板占位符。
- **文档里的路径必须真实存在**——读者会顺着点。
- **不要引入可执行物或规则校验**：不加 `.ps1`/`.js`/`.py`、不加 `package.json`/`requirements.txt`、不加**校验规则（checklist）** 的 workflow。
  `docs.yml` 只校验文档自身（链接、双语配对），不在禁区之列。需要自动化的人应当另建仓库消费本清单。
- 提交信息用 Conventional Commits，scope 取 `guide` / `spec` / `templates` / `docs`。

## 禁区

- 不新增第二份规则清单（会立刻产生漂移）。
- 不默认读者的 agent 工具：需要提到具体工具时，写成条件式（"若你用 Claude Code…"）。
- 不在文档里写"必须装 X"——除非那是被指导仓库自己的选择。
- 不提交个人配置（`.env`、本地路径、私有凭证）。

## 已知的坑

- **双语文档最容易漂移**：改一侧忘了另一侧。提交前用 `grep` 对照两版的小标题数量。
- **相对路径在多级目录里容易写错**：`guide/*.md` 引用 `docs/` 要写 `../docs/...`。
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

## 拿不准时

停下来问，并列 2–3 个选项与取舍。**不要**为了"看起来更专业"而给文档库加工具——那正是 ADR-0009 推翻的做法。
