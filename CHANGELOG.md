# Changelog

本文件记录**读者可感知的变化**：规则的增删与判据变化、章节与模板的结构变化。
格式遵循 [Keep a Changelog](https://keepachangelog.com/)，版本号遵循 [SemVer](https://semver.org/)。
更细的过程（谁在什么时候改了什么）看 `git log` 与 `docs/adr/`。

## [Unreleased]

### Changed —— 仓库元数据改完了（不在 diff 里）

- **About 描述换成英文**：`What an agent-ready GitHub repo should look like: a spec (L0–L3), an eight-chapter
  guide, and templates. Documentation only — no checker, no executables.`
  原来的中文描述还挂着"体检器"——那是 ADR-0009 删掉的东西。第一版里有 `48 rules`，已删：
  条数随版本变化，写死它等于再埋一颗本库正在拆的雷。
- **topics 从 8 个删到 4 个**：去掉 `powershell` / `code-quality` / `developer-tools`（本库既没有 PowerShell，
  也不做代码质量检查），另去掉 `claude-code`——AGENTS.md 的禁区写着"不默认读者的 agent 工具"，
  挂某个具体工具的 topic 等于替它背书。保留 `agent-governance` `agents-md` `ai-agents` `repository-spec`。
- **顺手记一条 API 陷阱**：`PATCH /repos` 会**静默忽略** `topics` 字段——返回 200、`description` 生效、
  `topics` 一个没变、没有任何报错。改 topics 必须走 `PUT /repos/{owner}/{repo}/topics`（字段名是 `names`）。
  与 `POST /pulls` 静默忽略 `assignees` 同一类：**GitHub 回 2xx 不代表你传的字段都生效了。**

### Fixed —— 把"这一步改不了"的真正原因写对

- `CHANGELOG.md` 1.5.0 节里那句"GitHub App 没有 Repository **metadata** 权限，`PATCH /repos` 返回 **422**，
  这一步改不了"**三处都不对**：改描述需要的是 `administration`，不是 `metadata`（后者一直是 `read`）；
  实际报错是 `403 Resource not accessible by integration`；真正原因是 **installation 没批准 App 新申请的权限**，
  而不是 App 没申请。已就地改正——改的是已发布节里的**状态句**，不是变更事实本身。
- 新增证据 [`docs/evidence/2026-11-18-github-app-permission-propagation.md`](docs/evidence/2026-11-18-github-app-permission-propagation.md)：
  App **申请**的权限 / installation **批准**的权限 / token **实际拿到**的权限，三处逐一回读——
  `administration` 只在第一处出现。批准之前重签 token 无效。
- `guide/05`（中英）自锁附录第 3 条补上这个陷阱：**判断 token 有没有某项权限，看 `token.permissions`
  里有没有那个 key，别看 App 设置页的勾选。**

### Fixed —— 昨天写下的条数今天就过期了

- `docs/adr/0008`：两条出路里的"给 `spec/checklist.md`（**37 条**）出英文版"与"这张 **37 行**大表"改成
  不写死条数的说法。这段是 #34 昨天合进去的，#35 把条目加到 48 条之后**当天就变成假话**——
  正是这个库一直在修的那类"事实腐烂"，只不过这次修的是它自己刚写下的。
- `docs/adr/0011`：背景句补上版本锚点，"把 **1.4.0 的** 37 条摊开数一遍"。
  同文件里"37 → 48"那两处是对的（本来就在描述这次跃迁），不动。

## [1.5.0] - 2026-11-18

### Fixed —— 扫掉 ADR-0009 的残留引用

- `SECURITY.md` **整篇重写**：原文描述的是已删除的检查器（"检查器是**只读**的"、`rules.json` 里的正则、
  `md-refs-exist`、`-Level 3`、`Test-Path` 只作用于 `-Target`），上报口径也还是"误报 / 漏报 / 引擎本身的执行问题"。
  新口径按"**没有可执行代码，可执行的是文本**"重写：文档被 agent 当作指令执行、模板照抄成假闸门、外部行为漂移。
  影响类型从三种改为四种：**判据错了 / 模板有害 / 引用失效 / 指令注入**。
- `SECURITY.md` 改为英文默认版，新增 `SECURITY.zh-CN.md`（ADR-0008 第 4 条：默认文件名 = 主要读者的语言；
  此前 `SECURITY.md` 是中文单语，英文读者从 README 点进去会掉进另一种语言）。
- `CONTRIBUTING.md`：示例提交信息把 `R042` 写成"检查 `docs/` 下的死链"，与唯一事实源不符（`R042` = AGENTS.md 声明输出语言）。
- `spec/checklist.md`：删掉文件末尾悬挂的 `## 不同级别的差异`（标题下只有一句孤立的话，是旧 README 的残留），
  换成"判完一条之后"——给出三种结论，以及"跳过 + 理由"该落在哪。
- `spec/checklist.md` `R002` 的"怎么改"：从 5 段改为指向 [guide/03 §2](guide/03-文档该怎么写.zh-CN.md) 的八段骨架与
  `templates/AGENTS.md.tmpl`，消除清单与模板之间的段落数漂移。
- `README.md` / `README.zh-CN.md`：证据描述从"十个真实仓库"改为两批按日期存档的采样
  （10 个仓库的文件面 + 12 个仓库的 agent 指令面）。
- `guide/README.{md,zh-CN.md}`："回答六件事"改为八件事并与八章一一对应（07 章此前不在列表里）；
  英文版 `How to read` 里残留的一句中文括注改回英文。

### Added —— 这套规范从此可以被"符合"

- `spec/README.md` 新增「**符合性声明**」一节：声明"本仓库符合 `agent-ready-repo-spec 1.4.0`，目标档位 L2"的
  **四个条件**（全部 `must` 满足 / 每个偏离的 `should` 有书面理由 / 采用记录落在被管理的仓库内 / `may` 不计分），
  并把 `must` / `should` / `may` 对齐到 RFC 2119 的 MUST / SHOULD / MAY。
  在此之前它有规则 ID、有严重度、有 SemVer、有"唯一事实源"，却没有任何一句话回答"**满足什么才算符合**"——
  没有符合性定义的规范只是建议。
- `spec/README.md` 新增「编号」一节：号段按档位预留（`R001`–`R009`=L0、`R010`–`R019`=L1、`R020`–`R029`=L2、
  `R030`–`R049`=L3、`R050` 起=需要看 `git log`）、**永不复用**、新增只往后加。
  `R006`–`R009`、`R017`–`R019`、`R043`–`R049` 不出现是**预留**而不是缺条——
  已用 `git log --all -S` 核对全部历史提交，这些号从未被分配过。
- `spec/checklist.md` 顶部补号段说明与符合性指针；`spec/agent-playbook.md` §2 补"可以替他核对四个条件，但不要替他声明"。
- `AGENTS.md` 补「语言约定」与「命令（唯一权威）」两节：本库此前**自己违反刚发布的 `R042`**（没有语言约定）
  与 `R031`（没有命令一节），而 `docs/adr/0008-bilingual-equal-status.md` 结尾还指向一个当时并不存在的「语言约定」一节。

### Changed —— 级别表不再重复判据

- `spec/README.md` 的四级表去掉"达到它意味着有 README / CONTRIBUTING / …"那一列，只留"这一档在解决什么问题"。
  那一列与 checklist 的严重度**互相矛盾**：把 `R005`（CI，`should`）与 `R010`（CONTRIBUTING，`may`，
  且正文明说"不是 agent 就绪的必要条件"）写成达标条件，又在 L3 写了"可回滚"而清单里没有任何回滚条目。
  它本身就是 `AGENTS.md` 禁止的"第二份规则陈述"。
- `spec/README.md`「规范不覆盖什么」补一条：不替你评"你该到哪一级"。

### Fixed —— 渲染、失效落点与双语漂移

- 修掉 **10 处字面 `` `n `` 转义残留**（`CHANGELOG.md`、`docs/index.md`、`guide/README.md`、`guide/README.zh-CN.md`）：
  列表项与表格行曾被拼进上一行，页面上是乱码。
- `examples/small-repo/CONTRIBUTING.md`、`examples/medium-repo/CONTRIBUTING.md`：删掉 2 个 `0x0C` 控制字符，
  分支名此前渲染成 `eat/<slug>`、`ix/<slug>`。
- `templates/adoption.md.tmpl`、`guide/00`：采用记录的"落点"不再指向已删除的 `spec-check.ps1` / `-Level`。
- `templates/settings.json.tmpl`：deny 补 `Edit(./AGENTS.md)`、`Edit(./CLAUDE.md)`——治理面此前可被 agent 直接改。
- `templates/AGENTS.md.tmpl`：补「语言约定」一节（`R042` 的唯一落点）；`[README.md](README.md)` 改纯文本，不再被判为断链。
- `templates/prompt-github-app-git.md.tmpl`：`iss` 放宽为 App ID / Client ID（官方推荐 Client ID）；`GH_TOKEN` 只对 `gh` 生效；
  bot noreply 邮箱改用 `{{BOT_USER_ID}}`；自检项不再写死"五个检查"。
- `guide/04-Agent怎么用.md`：补回英文版缺失的「7. Sources」整节，中英标题数恢复一致。
- 计数与引用：`README.md` 36→37；`AGENTS.md` 七章→八章；`guide/01` 与
  `docs/evidence/2026-11-17-repo-sampling.md` 的根 `CHANGELOG.md` 比例 4/10→3/10；
  `guide/README` 去掉 `check.kind`、`rules/`、`checker/` 残留引用；`guide/06.zh-CN.md` 第 3 节子编号 2.x→3.x；
  `guide/02.zh-CN.md` 改链中文版 01 章；`bug.yml` 占位版本 1.3.0→1.4.0。
- `guide/05.zh-CN.md`：admin 强制状态改为"已开启"（原句引用的是已被 ADR-0004 取代的 ADR-0003）；
  `guide/07.zh-CN.md`：`bypass_actors` 与 `administration` 权限不再混为一谈。

### Changed —— 口径统一：没有规则引擎，只有文档一致性检查

- `README.md` / `README.zh-CN.md` / `AGENTS.md` / `CONTRIBUTING.md` / `.github/PULL_REQUEST_TEMPLATE.md`：
  "没有 CI 门禁 / 没有 CI 校验 / 不加 workflow 校验"统一改为"**没有规则引擎**，只保留 `docs.yml` 的链接检查与双语配对，
  它们校验文档自身、不校验规则"。
- 理由：旧表述与本库现状矛盾（`docs.yml` 就是必需检查），且会诱导 agent 把 `docs.yml` 当作违规物删掉——
  那正好复现 ADR-0010 的必需检查自锁。ADR-0009 早已留出"平台自带必需检查"的口子，此处只是把口径补齐。
- `guide/00`：中文版"未采用项"改为"对 `checklist.md` 的机器校验 + agent 权限基线"；
  英文版原有的"未采用 approvals ≥ 1"与 `guide/07` §8 记录的 ruleset 冲突，一并修正。
- 两版都补了一行 `CODEOWNERS 目前不生效`（ruleset 未开 `Require review from Code Owners`）——此前只有英文版有。
- `guide/README.{md,.zh-CN.md}`：去掉对已删除目录 `rules/`、`checker/` 的引用。

### Added —— 规则 ↔ 章节 ↔ 证据 三向可追溯

- `spec/checklist.md` 新增「章节索引」：八章各自解释哪些条目、主要证据在哪，并**明写两个不对称**
  （有章节没条目：00 章的采用记录、05/07 章论证的门禁；有条目没章节：`R050`/`R051` 没有正面讲的一节）。
  只做导航、不含判据——判据仍然只有下面那张分级表。
- `guide/01`、`02`、`04`、`05`、`06`、`07` 各补一节「附：本章对应的自查项」（中英共 12 个文件），照 `guide/03` 已有的样式。
  此前八章里**只有 03 章引用了规则 ID（6 个），其余七章引用数为 0**：章节给结论、清单给判据，两边互不认识。
- `guide/05`、`07` 的附录里直写"本章论证的门禁还不是条目，这是覆盖缺口，不是决定不收"。
- `README.md` / `README.zh-CN.md` / `ADR-0008` 新增双语**覆盖范围**的如实声明：
  `guide/` + `README` + `examples/README` + `SECURITY` 双语（`双语配对` 执行的就是这个范围），
  `spec/`（含 `checklist.md`）、`docs/`、`CONTRIBUTING.md`、`CHANGELOG.md`、`AGENTS.md`、`templates/` 仅中文。
  ADR-0008 给出两条出路（缩小声明范围 / 给 `checklist.md` 补英文版）并**不替这个选择背书**。

### Fixed —— 证据口径

- `guide/06`：`ROADMAP*` / `STATUS|PROGRESS|PLAN*` 的 `0/10` 明确限定为**根目录**统计，
  并说明 `microsoft/vscode` 把 roadmap 放在功能目录的反例要解决的是"计划与代码一起腐烂"，不是"该不该有"。
- `guide/01`：`AGENTS.md` 由"已经是主流"改为"已经常见（本次抽样的 10 个头部仓库里 6 个有）"，并注明样本非随机、偏开源大仓。
- `docs/evidence/2026-11-18-agent-docs-sampling.md`：原"原始样本存本机 `_samples/`、不入库"一段换成
  「复现与局限」——固定 commit 链接格式、样本偏向、比例结论必须标样本量、第三方全文不入库。
- `docs/evidence/2026-11-17-protection-probe.md`：加「有效性」一行，说明 4 个旧 context 已被 ADR-0010 取代。

### Changed —— `双语配对` 同时校验中英标题数

- `.github/workflows/docs.yml` 的 `双语配对` job 新增一步：对 `guide/*.md` 全部配对、`README.md`、`examples/README.md`
  比较两侧 `^#{1,6} ` 的计数，不等即报 `::error` 并列出两个数字。
- **job 名未变**（仍是 `双语配对`），因此 ruleset 不需要改动——改名会撞上 ADR-0010 记录的自锁。
- 覆盖的约定：`AGENTS.md`「改内容必须在同一个 PR 内同步两边，只改一侧视为未完成」此前没有任何执行点。

### Changed —— 版本锚点与仓库元数据

- `.gitattributes`：`*.md` / `*.tmpl` / `*.yml` 标 `linguist-documentation`。此前仓库首页语言条显示 **Go Template**
  （`templates/` 下 8 个 `.tmpl` 被 linguist 当成代码），与"纯文档库"的定位互相打脸。
  顺带删掉一条悬挂注释：`# 生成物：在 PR 里折叠` 下面已经没有规则（`spec/RULES.md` 随 ADR-0009 一起删了）。
- **仓库元数据**（不在 diff 里，走 API 改）：About 描述去掉"体检器"（ADR-0009 已删）；
  topics 去掉 `powershell` / `code-quality` / `developer-tools`——本库既没有 PowerShell，也不做代码质量检查。
  **1.5.0 发布时未执行**：`PATCH /repos` 返回 `403 Resource not accessible by integration`——App 申请了 `administration`，
  但 installation 没批准这次扩权，token 里根本没有这个 key。
  **已于 2026-11-18 扩权批准后执行完成**：描述改为英文，topics 另删 `claude-code`（见 `[Unreleased]`）。
  原因与恢复路径见 [证据](docs/evidence/2026-11-18-github-app-permission-propagation.md)。
- **版本锚点**（不在 diff 里，走 API 建，**已完成**）：新增 tag `v1.4.0`（→ `7b66cc3`）与对应 Release；
  给 `v1` 补了 Release 页并标 *Superseded / 请勿使用*。
  此前唯一的 tag 是 `v1` → `d60c3cc`，即**含 `checker/` 与 `action.yml` 的旧树**（ADR-0009 之前的形态）；
  而 `SECURITY.md` 承诺"只对最新 `specVersion` 提供修复"、`spec/README.md` 定了 SemVer 策略，
  却没有任何一个可用的 tag 或 Release 能锚定"最新"是哪一个——下游仓库无法固定引用。

### Added —— 11 条 GitHub 管理面与 agent 治理条目

新增条目全是 `should` / `may`，按版本策略属 **minor**。它们补的是同一个缺口：本库的立意是
"agent 参与 GitHub 开发**或管理**"，但 37 条里约六成在问"文件在不在"，**"管理"这一半只存在于 `guide/07` 的正文里，一条规则都没有**。

**L2（`R060`–`R063`，均 `should`）**

- `R060` `main` 受保护：必须 PR + 必需检查 + 禁止删除与强推，且对 admin 也生效。
- `R061` workflow 显式声明 `permissions`；第三方 Action 固定到 commit SHA。
  ——本库 `docs.yml` 早就这么做并写明理由，却没有条目要求别人也这样：**实践与规则脱节**。
- `R062` agent 使用的凭证为最小权限，且不落盘、不进 remote URL。
- `R063` 采用记录存在于**被管理的那个仓库内**——`guide/00` 的"每个采用必须有落点"从此有了判据。

**L3（`R043`–`R049`）**

- `R043`（`should`）必需检查名与 job 名**逐字一致**，改名走"先加新 job → 改 ruleset → 下个 PR 删旧"。
  ADR-0010 那次 main 锁死的真实事故，从此有条目可挂。
- `R044`（`should`）治理面独立 owner 且 agent 不得自行修改；点明"不开 `Require review from Code Owners`，
  `CODEOWNERS` 就只是一份索引"。
- `R045`（`should`）`AGENTS.md` 声明哪些来源是**不可信输入**，且不得因仓库内容放宽禁区——
  此前本库对提示注入**一个字都没提**。
- `R046`（`may`）若用 Copilot：仓库级指令文件存在且不与 `AGENTS.md` 双写。
  vscode 14.5 KB / deno 12.3 KB / supabase 6.5 KB 的实测证据，此前没有转化成规则。
- `R047`（`may`）跨工具 agent 资产落 `.github/`、工具独占落工具目录，且只有一处事实源。
- `R048`（`may`）PR 层面声明 agent 参与。显式承认 `kubernetes/kubernetes` 的相反做法（禁止 trailer、改为 PR 声明）
  同样成立，因此**不推翻 `R029`**，两层线索并存。
- `R049`（`may`）agent 的改动可单独 revert——L3 判据里的"可回滚"此前没有任何条目。

### Changed —— 编号策略：号段不再承载级别

- L2 段（`R020`–`R029`）在 1.4.0 已用满，本版新 L2 条目从 `R060` 起分配。
  所以"号段 = 档位"从本版起**不再成立**；`spec/README.md` 与 `spec/checklist.md` 均改为：
  **级别以条目自己的"级别"列为准，号段只是一个永不复用的 ID。**
- `spec/README.md` 的「编号」一节按这个结论**改写**——#33 立的正是"号段 = 档位"，而本 PR 就是推翻它的那一个；
  顺手把「符合性声明」与 `spec/agent-playbook.md` 示例里的 `1.4.0` 同步成 `1.5.0`。
- 条目数 37 → 48；`specVersion` → **1.5.0**；`.github/ISSUE_TEMPLATE/bug.yml` 占位版本同步。
- `.github/PULL_REQUEST_TEMPLATE.md` 新增"本次是否有 agent 参与"一节（本库自己先满足 `R048`）。
- `spec/checklist.md`「章节索引」的 00 / 02 / 03 / 04 / 05 / 07 行按新条目更新；"两个已知的不对称"改写为
  "**1.5.0 之后剩下的不对称**"：门禁类已补齐，仍然有条目没章节的是 `R045`（不可信输入）与 `R061`（Actions 供应链）。
- `guide/00`、`05`、`07` 的「本章对应的自查项」附录同步（中英共 6 个文件）：那两处此前直写
  "本章论证的门禁还不是条目，这是覆盖缺口"，本 PR 把条目补上后那句话就成了假话，一并改掉；
  `guide/00` 补上缺失的附录（`R063`），让「章节索引」里"每章末尾都有反向附录"这句真的成立。

## [1.4.0] - 2026-11-18

### Changed —— 这个库不再包含任何可执行物

- **删除**：`checker/`（检查器与生成器）、`tests/`、`tools/`（发布与换 token 脚本）、`action.yml`、
  `.claude/` 与 `CLAUDE.md`、`.github/workflows/`、`.commitlintrc.json`、`rules/rules.json`、`spec/RULES.md`。
- **理由**：用某门语言写检查器，等于变相要求使用者装那门语言；仓库自带 `.claude/` 等于默认读者用 Claude。
  与"指导性文档、工具中立"的定位冲突。决策与代价见
  [ADR-0009](docs/adr/0009-spec-only-no-tooling.md)（取代 ADR-0001 / 0002 / 0006）。

### Added

- **[spec/checklist.md](spec/checklist.md)**：37 条规则连同 `id / 级别 / 是否 must / 为什么 / 怎么改`（本版新增 `R042`），
  成为**规则唯一事实源**（人可读，任何语言都能据此自行实现工具）。
- **[templates/prompt-github-app-git.md.tmpl](templates/prompt-github-app-git.md.tmpl)**：
  可直接粘给 agent 的提示词模板——凭证、JWT 硬规则（`iss` 用数字 App ID、UTC 时间戳）、
  git 身份两种方案（含 `GH007`）、联合署名、分支与 PR 四步、报错对照表、交付前自检。

- **`R042`（L3 · may）：AGENTS.md 声明输出语言**——agent 的语言默认跟着代码注释或上次输出走，不声明就会出现两种语言；它管的是"有没有声明"，不是"声明成什么语言"，因无真实事故支撑只到 `may`。
- **[examples/](examples/README.md)**：两份填好的对照样本（`small-repo` 路由型 ~9 行、`medium-repo` 约束+命令+验证+自动化地图），每节标注取自哪个真实仓库；显式把 `Co-authored-by` 与文件语言两处分歧摆出来让使用者选。
- **[guide/07-该开哪些设置](guide/07-该开哪些设置.md)**（中英两版）：合并方式、ruleset 九条、谁能绕过、Actions 默认值、安全项，以及"必需检查写错名字会锁死 main"那条；末节诚实记录本仓库自己**尚未核实**的项。
- **[docs/evidence/2026-11-18-agent-docs-sampling.md](docs/evidence/2026-11-18-agent-docs-sampling.md)**：12 个高星仓库的 agent 指令文件采样（四种形态、两处与本规范冲突的做法）。
- **[templates/prompt-locale.md.tmpl](templates/prompt-locale.md.tmpl)**：让 agent 按使用者母语工作的提示词片段，
  含"不翻译清单"（规则 ID / 路径 / 命令 / 标识符）与译文冲突时的处置。
- `guide/03` 的 `AGENTS.md` 骨架从六节扩为七节，新增「语言约定」一节（中英两版同步）。

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
