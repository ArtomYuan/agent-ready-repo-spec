# Changelog

本文件记录**读者可感知的变化**：规则的增删与判据变化、章节与模板的结构变化。
格式遵循 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [SemVer](https://semver.org/)。
更细的过程（谁在什么时候改了什么）看 `git log` 与 `docs/adr/`。

## [Unreleased]

### Changed —— 这个库不再包含任何可执行物

- **删除**：`checker/`（检查器与生成器）、`tests/`、`tools/`（发布与换 token 脚本）、`action.yml`、
  `.claude/` 与 `CLAUDE.md`、`.github/workflows/`、`.commitlintrc.json`、`rules/rules.json`、`spec/RULES.md`。
- **理由**：用某门语言写检查器，等于变相要求使用者装那门语言；仓库自带 `.claude/` 等于默认读者用 Claude。
  与"指导性文档、工具中立"的定位冲突。决策与代价见
  [ADR-0009](docs/adr/0009-spec-only-no-tooling.md)（取代 ADR-0001 / 0002 / 0006）。

### Added

- **[spec/checklist.md](spec/checklist.md)**：36 条规则连同 `id / 级别 / 是否 must / 为什么 / 怎么改`，
  成为**规则唯一事实源**（人可读，任何语言都能据此自行实现工具）。
- **[templates/prompt-github-app-git.md.tmpl](templates/prompt-github-app-git.md.tmpl)**：
  可直接粘给 agent 的提示词模板——凭证、JWT 硬规则（`iss` 用数字 App ID、UTC 时间戳）、
  git 身份两种方案（含 `GH007`）、联合署名、分支与 PR 四步、报错对照表、交付前自检。

### Changed

- Claude 相关条目（`.claude/settings.json`、`CLAUDE.md`、hooks、skills）在清单里改为**条件式表述**
  （"若你用 Claude Code…"），不再假设读者用它。
- 中文条目 `spec/README.md`、`spec/agent-playbook.md`、`CONTRIBUTING.md`、`docs/index.md`、
  `.github/` 下的模板全部按"没有工具"的现实重写。

## [1.3.0] - 2026-11-17

### Added

- 英文版正文：`guide/README`、`00`、`01`、`02`、`03`、`04`、`05`、`06`，默认文件为英文、中文加 `.zh-CN` 后缀。
- 提交历史类规则 `R050`（Conventional Commits）、`R051`（线性历史），均为 `may`，需要 `-Git`。

### Changed

- 语言策略：由"英文为事实源"改为**双语平权**（[ADR-0008](docs/adr/0008-bilingual-equal-status.md)），
  冲突时以**证据**裁定，不以语言裁定。
- `guide/06` 扩为「信息该放哪」：立项（范围/顺序/进度）、运行期（状态/待办/接手）、发布三块。

## [1.2.0] - 2026-11-17

### Added

- `guide/06` 发布期规范：什么时候发、版本号怎么定、Release notes 五段、什么时候才值得写 runbook。
- 规则 `R028`（提交规范的机器执行载体）、`R029`（agent 提交归属）。

### Changed

- `guide/06` 由「状态与待办」扩写为「信息该放哪」，新增"变化速度 → 载体"的判据。

## [1.1.0] - 2026-11-17

### Added

- `guide/00-接入决策`：十一项可选项、一次选好、每个"采用"必须有落点。
- `templates/adoption.md.tmpl`：采用记录模板（含"未采用项与理由"）。
- `docs/evidence/`：实测证据按采集日期存档。
- `guide/05` 收录 `cli/cli` 与 `python/cpython` 的真实 agent 门禁（贡献资格、停止条件）。

### Changed

- 发布流程要求 PR 描述必须写"下一步"（[ADR-0005](docs/adr/0005-publish-requires-next-step.md)）。

## [1.0.0] - 2026-11-16

### Added

- 规则集与检查器：四条级别（L0–L3）、三档严重度、`json` / `text` / `md` 三种输出。
- `guide/01`–`guide/04`：该有什么文档、目录结构、文档怎么写、agent 怎么用。
- `templates/`：`AGENTS.md`、PR 模板、CODEOWNERS、ADR、`settings.json`。
- 本仓库自己的落地：main 走 PR（[ADR-0004](docs/adr/0004-all-changes-via-pr.md)）。
