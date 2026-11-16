# AGENTS.md

> 本文件是 agent 的唯一事实源。人类入口见 [README.md](README.md)，规范正文见 [spec/README.md](spec/README.md)。

## 项目是什么

一个**规则库 + 检查器**：把“一个 agent 参与的 GitHub 仓库该长什么样”写成机器可读的 `rules/rules.json`，用 `checker/spec-check.ps1` 给任意仓库体检，输出自查清单（已有 / 建议补 / 跳过）与修复建议；加 `-Assess` 才给评分与达成等级（L0–L3）。

- 输入：任意本地目录
- 输出：`text` / `json` / `md`，退出码 0 通过 / 1 有未通过项 / 2 运行错误
- 不做：自动改目标仓库（修复由人或 agent 按 `fix` 建议执行）

## 命令（唯一权威，勿自行发明）

| 用途 | 命令 | 备注 |
|---|---|---|
| 体检（自查清单） | `pwsh ./checker/spec-check.ps1 -Target <path>` | 默认只列"已有/建议补"，不给分数与等级 |
| 评级（看分数） | `pwsh ./checker/spec-check.ps1 -Target <path> -Assess` | 才输出 score 与达成等级 |
| 机器可读输出 | `pwsh ./checker/spec-check.ps1 -Target <path> -Format json` | CI 用 |
| 生成规则表 | `pwsh ./checker/gen-rules-doc.ps1` | 改完 `rules/rules.json` 必跑 |
| 自测 | `pwsh ./tests/selftest.ps1` | 临时 fixture，无需联网 |
| 自己体检自己 | `pwsh ./checker/spec-check.ps1 -Target . -Assess` | 提交前必跑，必须达成 L3 |
| 提交历史体检 | `pwsh ./checker/spec-check.ps1 -Target . -Git` | 需 git；无 git/非仓库时 R050/R051 跳过，不扣分 |

Windows 上执行策略为 `Restricted` 时，把 `pwsh` 换成 `powershell -NoProfile -ExecutionPolicy Bypass -File`。
本仓库**没有** Node/Python 依赖；不要引入包管理器。

## 目录地图

- `rules/rules.json` — 规则唯一事实源。改规则只改这里。
- `spec/RULES.md` — 生成物，**不要手改**；改了会被 CI 发现不一致。
- `spec/agent-playbook.md` — agent 操作手册（先读这个再动手）。
- `checker/spec-check.ps1` — 引擎。16 种 `check.kind`，见文件内 `switch`；`-Git` 才读提交历史。
- `checker/gen-rules-doc.ps1` — 从 JSON 生成 Markdown 表。
- `templates/` — 复制到目标仓库的模板，含 `{{PLACEHOLDER}}`。
- `docs/` — 设计说明与 ADR。
- `.claude/` — 本仓库自己的权限与 skill。

## 硬约定

- **规则的唯一事实源是 `rules/rules.json`**；`spec/RULES.md` 是生成物，手改视为错误。
- 新增规则必须：分配唯一 `id`（按级别分段：L0 用 `R0xx`、L1 用 `R1xx`、L2 用 `R2xx`、L3 用 `R3xx`）、写 `rationale`（为什么）与 `fix`（怎么改）。
- 改规则语义（判定条件变化）→ 升 `specVersion` 并在 `CHANGELOG.md` 记一行。
- 检查器不引入第三方依赖；新 `check.kind` 必须在 `tests/selftest.ps1` 有对应 fixture。
- 提交信息：Conventional Commits，`feat(rules): ...` / `fix(checker): ...`。
- 文档里的路径必须真实存在（R037 会检查 `AGENTS.md`）。

## 禁区（由 hooks 与 R025/R036 共同约束）

- 不手改 `spec/RULES.md`（生成物）
- 不提交 `.claude/settings.local.json` 与 `CLAUDE.local.md`
- 不引入 Node/Python 依赖清单（`package.json` / `requirements.txt`）
- 不执行 `git push --force`、`git reset --hard`、`rm -rf`
- 不删除 `rules/` 下已有规则的 `id`（会让历史报告无法对齐）；废弃用 `"deprecated": true`

## 已知的坑

- **PowerShell 5.1 读取无 BOM 的 UTF-8 脚本会按 ANSI 解析**，中文引号会撕裂语法。`.ps1` 一律保存为 **UTF-8 with BOM**。
- `$PSScriptRoot` 在 `param()` 默认值里不可靠，路径默认值要在函数体里算（本仓库已这么写）。
- `ConvertFrom-Json` 在 5.1 默认深度 2，嵌套结构要显式 `-Depth 8`。
- Windows 执行策略 `Restricted` 会直接拒绝 `.ps1`；CI 与 hook 都必须带 `-ExecutionPolicy Bypass`。
- `Get-ChildItem -Filter` 与 `-Include` 语义不同，本仓库统一用 `-Filter` + 名称过滤。

## 提交与 PR

- 分支：`feat/<slug>`、`fix/<slug>`、`docs/<slug>`、`chore/<slug>`
- 描述用 [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)，含自检清单
- 提交前本地必跑：自测 + 自己体检自己（两条命令见上表）

## 拿不准时

停下来问，并列 2–3 个选项与取舍。**不要**为了让检查通过而放宽规则——规则是产品本身。
