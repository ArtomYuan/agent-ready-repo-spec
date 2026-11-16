# Changelog

本文件记录**用户可感知的行为变化**（规则的判定条件、检查器的输出/退出码）。
格式遵循 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [SemVer](https://semver.org/)。

## [Unreleased]

## [1.2.0] - 2026-11-17

按 GitHub 与 Anthropic 的**实际做法**校准提交规则（此前把个人偏好当成了行业基线）。

### Changed
- `R028`（提交规范执行载体）**should → may**。依据：`actions/checkout` 的 `CONTRIBUTING.md` 只给了一条外部链接，
  `github/docs` 根本没有提交格式文档，Claude Code 也不内置格式校验——它不是行业基线，只是"要自动发版时才需要"的升级项。
- `R041`（提交约定写进 AGENTS.md）**should → may**，并改写理由：Claude Code **默认自带**提交/PR 指令
  （`includeGitInstructions` 默认 `true`），真正的风险是"仓库约定与内置指令打架"，而不是"没写 Conventional Commits"。

### Added
- `R029`（L2 · should）**保留 agent 提交归属**：`settings.json` 里不得把 `attribution` 设为 `false`
  或把 `attribution.commit` 设为空串。依据：Claude Code 默认给提交加 `Co-Authored-By: <model> <noreply@anthropic.com>`
  git trailer，这是 agent 参与最便宜的审计手段。
- 新 `check.kind`：`json-forbid`（共 16 种）。
- spec 文档新增「上游依据」小节，逐条写明每条提交规则对应哪家的做法。

### Notes
- 早期指南里自创的 `Agent: <name> <model>` trailer **作废**：官方机制是标准 git trailer + `attribution` 设置，
  自造 trailer 会让 `git interpret-trailers` 与后续工具链读不到。

## [1.1.0] - 2026-11-17

### Added
- **4 条提交规则**：
  - `R028`（L2 · should）提交规范要有机器执行载体（commitlint 配置），不能只写在 CONTRIBUTING 里；
  - `R041`（L3 · should）`AGENTS.md` 必须声明提交格式——agent 只看这个文件；
  - `R050`（L3 · may，opt-in）最近 50 条提交 subject 符合 Conventional Commits 且 ≤72 字符；
  - `R051`（L3 · may，opt-in）最近 50 条提交是线性历史（无 merge commit）。
- 新 `check.kind`：`git-commit-subject`、`git-commit-no-merge`（共 15 种）。
- 新开关 `-Git`：默认**不读**提交历史；未开启、git 缺失、或目标不是 git 仓库时，规则状态为
  `skipped`——**不计分、不计入达成等级、不触发退出码**，报告里显示 `[skip]`。
- `.commitlintrc.json` + CI 的 `commits` job：PR 内每条提交过 commitlint。
- `tests/selftest.ps1` 新增 5 条断言（默认跳过、`-Git` 下非 git 目录仍跳过、跳过不扣分不降级）。

### Changed
- `specVersion` 1.0.0 → **1.1.0**（新增 should/may 规则，属 minor；不收紧既有判定）。
- CI 的体检 job 改用 `-Git` 并 `fetch-depth: 0`，提交历史规则在 CI 里真正生效。

### Fixed
- `spec/RULES.md` 生成时统一 LF。此前 Windows 上生成 CRLF，导致 Linux CI 的 `gen-rules-doc.ps1 -Check` 失败。
- 检查器不再依赖 `Get-Item` / `Resolve-Path`：Linux 上点文件（`.gitignore`）取不到，会让整次体检直接崩溃。
  改用 `[System.IO.File]::ReadAllBytes()` 与 `[System.IO.Path]::GetFullPath()`。

## [1.0.0] - 2026-11-16

### Added
- `rules/rules.json`：31 条规则，分 L0–L3 四级、must/should/may 三档，每条带 `rationale` 与 `fix`。
- `checker/spec-check.ps1`：无依赖检查引擎，支持 13 种 `check.kind`，输出 `text` / `json` / `md`，
  退出码 0 通过 / 1 有未通过项 / 2 运行错误。
- `checker/gen-rules-doc.ps1`：从 `rules.json` 生成 `spec/RULES.md`，CI 校验生成物是否最新。
- `spec/agent-playbook.md`：agent 用本规范管理仓库的操作手册（体检 → 分诊 → 修复 → 升级等级）。
- `templates/`：`AGENTS.md`、`settings.json`、`CODEOWNERS`、PR 模板、ADR 模板。
- `.claude/`：本仓库自己的权限基线（`permissions.deny`）与两个 skill（`audit-repo` / `bootstrap-repo`）。
- `tests/selftest.ps1`：用临时 fixture 验证引擎行为（好仓库全绿 / 空仓库全红 / 危险仓库精准命中）。

### Changed
- 与早期指南版相比，**删除了路径拦截脚本**：这类需求由 `permissions.deny` 的 `Edit(...)` 规则声明式完成。
  只有语义判断（如“force push 到 main 但允许推 feature 分支”）才保留 hook 脚本。

### Notes
- 规则里刻意**没有**“必须用某个 CI 厂商”“必须有某个脚本”这类规则——规范只管可验证的结构与痕迹。
