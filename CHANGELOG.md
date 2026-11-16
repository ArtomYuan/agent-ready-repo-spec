# Changelog

本文件记录**用户可感知的行为变化**（规则的判定条件、检查器的输出/退出码）。
格式遵循 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [SemVer](https://semver.org/)。

## [Unreleased]

### Action（`action.yml`）

- 首次发布：composite action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入。
  inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
- 修复：参数改为**哈希表 splatting**。此前用数组 splatting，而数组传的是位置参数，
  导致 `Cannot convert "." to System.Int32`——action 必然失败。
- `v1` 是**移动 tag**，跟随最新的 v1.x；生产环境请固定 commit SHA（见 [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) 与 ADR-0006）。
- **inputs 改名属于破坏性变更**：会同时影响 `v1` 用户，必须升 major 并另起 `v2` tag。
### Added

- **`tools/gh-app-token.ps1`**：用 GitHub App 私钥换 installation token，不依赖 git/gh/node/openssl
  （PKCS#1 → PKCS#8 → CNG → RS256 → JWT）。`publish-pr.ps1` 新增 `-AppId` / `-InstallationId` / `-PrivateKeyPath`，
  不再依赖 PAT；提交自动带 `Co-authored-by`，PR 自动 `cc @` + 设 assignee。
- 新增指导章节 [guide/00-接入决策.md](guide/00-接入决策.md)：十一项可选项、一次选好、
  每个"采用"必须有落点（门禁 / `settings.json` / CI job / `AGENTS.md`），决定留在被管理的仓库里。
- 新增模板 [templates/adoption.md.tmpl](templates/adoption.md.tmpl)：采用记录（含"未采用项与理由"）。

### Action（`action.yml`）

- 首次发布：composite action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入。
  inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
- 修复：参数改为**哈希表 splatting**。此前用数组 splatting，而数组传的是位置参数，
  导致 `Cannot convert "." to System.Int32`——action 必然失败。
- `v1` 是**移动 tag**，跟随最新的 v1.x；生产环境请固定 commit SHA（见 [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) 与 ADR-0006）。
- **inputs 改名属于破坏性变更**：会同时影响 `v1` 用户，必须升 major 并另起 `v2` tag。
### Added

- **`tools/gh-app-token.ps1`**：用 GitHub App 私钥换 installation token，不依赖 git/gh/node/openssl
  （PKCS#1 → PKCS#8 → CNG → RS256 → JWT）。`publish-pr.ps1` 新增 `-AppId` / `-InstallationId` / `-PrivateKeyPath`，
  不再依赖 PAT；提交自动带 `Co-authored-by`，PR 自动 `cc @` + 设 assignee。
- **`action.yml`**：composite GitHub Action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入（ADR-0006）。
  inputs：`target` / `level` / `fail-on` / `assess` / `git` / `format`；`v1` 为移动 tag，生产建议固定 SHA。
- **`guide/06` 新增「发布期」一节**：什么时候该发（三个触发、三个不该发的理由）、semver 判定、
  Release notes 的五段结构，以及"什么时候才值得为发布写 runbook"。
- **双语结构**（ADR-0007）：`README.md` 改为英文，中文镜像 `README.zh-CN.md`；约定"默认英文、
  中文加 `.zh-CN`、英文为事实源"，并给出逐章翻译顺序。
- CI 新增 `action-smoke` job：用 `uses: ./` 跑一遍 `action.yml`（不设为必需检查，避免自锁）。

### Changed
- **双语平权**（ADR-0008，取代 ADR-0007 第 2 条）：两版地位相同、同一 PR 内同步；冲突时**以证据裁定**，
  不以语言裁定。默认文件名只表示主要读者，不代表等级。
- **`publish-pr.ps1` 支持复用已存在的 PR**：同一 `-Branch` 重复发布时，会 force-update 分支、更新标题与正文后
  复用原 PR（关闭过的会重开）。此前检查失败后重发会撞"PR 已存在"，必须手工关 PR + 删分支。
- **全部章节双语化**：`guide/` 七章 + 索引，默认文件为英文、中文同级 `.zh-CN.md`；
  中文镜像为同名 `.zh-CN.md`；根 `README.zh-CN.md` 的链接改指中文镜像。
- 修正过期表述：GitHub 仓库描述与 `publish-github.ps1` 默认值不再写死规则条数（原为"31 条"，实际已 36 条）；
  `README` 顶部改为描述当前输出形态（默认自查清单、`-Assess` 才评级），并新增「能力边界」一句。
- **发布参数 `-Next` 改为必填**（ADR-0005）：PR 描述固定四段（改了什么 / 下一步 / 非目标 / 怎么验证的），
  并写进 squash 提交正文。缺 `-Next` 直接发布失败；没有后续时显式写 `"无"`。
- **发布流程改为走 PR**：新增 `tools/publish-pr.ps1`（分支 → PR → 等 CI → squash 合并）。
  main 开启分支保护（Require a pull request + Required status checks + Do not allow bypassing），
  直推会被拒绝。`tools/publish-github.ps1` 降级为"新仓库首次引导"专用。详见 ADR-0004。

## [1.3.0] - 2026-11-17

定位澄清：本库是**指导性**的，检查器只是自查工具——所以两处都往"少做判决"的方向调。

### Changed
- `R010`（CONTRIBUTING）**should → may**。它写给人看、agent 不加载；缺它不该让一个只差这一项的仓库被判成 L0。
- `specVersion` 1.2.0 → 1.3.0（放宽判定，minor）。
- 默认输出改为**自查清单**：只报"已有 / 建议补 / 跳过"，不再出现分数、达成等级与"通过/未通过"字样。

### Action（`action.yml`）

- 首次发布：composite action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入。
  inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
- 修复：参数改为**哈希表 splatting**。此前用数组 splatting，而数组传的是位置参数，
  导致 `Cannot convert "." to System.Int32`——action 必然失败。
- `v1` 是**移动 tag**，跟随最新的 v1.x；生产环境请固定 commit SHA（见 [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) 与 ADR-0006）。
- **inputs 改名属于破坏性变更**：会同时影响 `v1` 用户，必须升 major 并另起 `v2` tag。
### Added

- **`tools/gh-app-token.ps1`**：用 GitHub App 私钥换 installation token，不依赖 git/gh/node/openssl
  （PKCS#1 → PKCS#8 → CNG → RS256 → JWT）。`publish-pr.ps1` 新增 `-AppId` / `-InstallationId` / `-PrivateKeyPath`，
  不再依赖 PAT；提交自动带 `Co-authored-by`，PR 自动 `cc @` + 设 assignee。
- `-Assess` 开关：要评分与达成等级时才加。**退出码不受影响**（仍由 `-FailOn` 决定），`-Format json` 的字段也不变，CI 与下游脚本无需改动。
- 3 条自测断言覆盖两种输出模式（共 22 项）。

### Notes
- `should` 从此只用于"不写就会咬人"的结构事实；凡是"人多半会自己判断"的，一律 `may`。

## [1.2.0] - 2026-11-17

按 GitHub 与 Anthropic 的**实际做法**校准提交规则（此前把个人偏好当成了行业基线）。

### Changed
- `R028`（提交规范执行载体）**should → may**。依据：`actions/checkout` 的 `CONTRIBUTING.md` 只给了一条外部链接，
  `github/docs` 根本没有提交格式文档，Claude Code 也不内置格式校验——它不是行业基线，只是"要自动发版时才需要"的升级项。
- `R041`（提交约定写进 AGENTS.md）**should → may**，并改写理由：Claude Code **默认自带**提交/PR 指令
  （`includeGitInstructions` 默认 `true`），真正的风险是"仓库约定与内置指令打架"，而不是"没写 Conventional Commits"。

### Action（`action.yml`）

- 首次发布：composite action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入。
  inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
- 修复：参数改为**哈希表 splatting**。此前用数组 splatting，而数组传的是位置参数，
  导致 `Cannot convert "." to System.Int32`——action 必然失败。
- `v1` 是**移动 tag**，跟随最新的 v1.x；生产环境请固定 commit SHA（见 [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) 与 ADR-0006）。
- **inputs 改名属于破坏性变更**：会同时影响 `v1` 用户，必须升 major 并另起 `v2` tag。
### Added

- **`tools/gh-app-token.ps1`**：用 GitHub App 私钥换 installation token，不依赖 git/gh/node/openssl
  （PKCS#1 → PKCS#8 → CNG → RS256 → JWT）。`publish-pr.ps1` 新增 `-AppId` / `-InstallationId` / `-PrivateKeyPath`，
  不再依赖 PAT；提交自动带 `Co-authored-by`，PR 自动 `cc @` + 设 assignee。
- `R029`（L2 · should）**保留 agent 提交归属**：`settings.json` 里不得把 `attribution` 设为 `false`
  或把 `attribution.commit` 设为空串。依据：Claude Code 默认给提交加 `Co-Authored-By: <model> <noreply@anthropic.com>`
  git trailer，这是 agent 参与最便宜的审计手段。
- 新 `check.kind`：`json-forbid`（共 16 种）。
- spec 文档新增「上游依据」小节，逐条写明每条提交规则对应哪家的做法。

### Notes
- 早期指南里自创的 `Agent: <name> <model>` trailer **作废**：官方机制是标准 git trailer + `attribution` 设置，
  自造 trailer 会让 `git interpret-trailers` 与后续工具链读不到。

## [1.1.0] - 2026-11-17

### Action（`action.yml`）

- 首次发布：composite action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入。
  inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
- 修复：参数改为**哈希表 splatting**。此前用数组 splatting，而数组传的是位置参数，
  导致 `Cannot convert "." to System.Int32`——action 必然失败。
- `v1` 是**移动 tag**，跟随最新的 v1.x；生产环境请固定 commit SHA（见 [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) 与 ADR-0006）。
- **inputs 改名属于破坏性变更**：会同时影响 `v1` 用户，必须升 major 并另起 `v2` tag。
### Added

- **`tools/gh-app-token.ps1`**：用 GitHub App 私钥换 installation token，不依赖 git/gh/node/openssl
  （PKCS#1 → PKCS#8 → CNG → RS256 → JWT）。`publish-pr.ps1` 新增 `-AppId` / `-InstallationId` / `-PrivateKeyPath`，
  不再依赖 PAT；提交自动带 `Co-authored-by`，PR 自动 `cc @` + 设 assignee。
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

### Action（`action.yml`）

- 首次发布：composite action，`uses: ArtomYuan/agent-ready-repo-spec@<ref>` 一行接入。
  inputs：`target`（默认 `.`）、`level`（0–3）、`fail-on`（`must` / `should` / `none`）、`assess`、`git`、`format`。
- 修复：参数改为**哈希表 splatting**。此前用数组 splatting，而数组传的是位置参数，
  导致 `Cannot convert "." to System.Int32`——action 必然失败。
- `v1` 是**移动 tag**，跟随最新的 v1.x；生产环境请固定 commit SHA（见 [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) 与 ADR-0006）。
- **inputs 改名属于破坏性变更**：会同时影响 `v1` 用户，必须升 major 并另起 `v2` tag。
### Added

- **`tools/gh-app-token.ps1`**：用 GitHub App 私钥换 installation token，不依赖 git/gh/node/openssl
  （PKCS#1 → PKCS#8 → CNG → RS256 → JWT）。`publish-pr.ps1` 新增 `-AppId` / `-InstallationId` / `-PrivateKeyPath`，
  不再依赖 PAT；提交自动带 `Co-authored-by`，PR 自动 `cc @` + 设 assignee。
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
