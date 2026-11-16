# Changelog

本文件记录**用户可感知的行为变化**（规则的判定条件、检查器的输出/退出码）。
格式遵循 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [SemVer](https://semver.org/)。

## [Unreleased]

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
