# 规则索引

> **只做导航：判据正文在各规则文件里，本表不含任何判定。**
> 默认按档位排；要按板块找就 Ctrl-F 目录名。
>
> `旧号` 是 1.x 时代的 `R0xx`，**永久保留、不改不复用**——历史 PR、CHANGELOG、ADR 与下游采用记录
> 都指着它。新引用一律用 `板块/主题`；旧引用继续有效，由本表对齐。
>
> **ID 不等于路径**：一个板块下是若干**主题文档**，每条规则是其中一节。索引那一行的链接指向
> 承载它的文档，不是一条规则一个文件。

> **已知漂移面**：本表的「判据」列与各文件 H1 是同一句话，「级别」列与各文件首行注释也是同一份数据。
> 改一条规则时**两处一起改**。本库不提供检查器（ADR-0009），所以这一致性由人和 agent 逐字核对。

## 板块 ↔ 章节

| 板块 | 条数 | 对应章节 | 主要证据 |
|---|---:|---|---|
| [adoption/](adoption/) | 1 | [00 · 接入决策](../../guide/00-接入决策.zh-CN.md) | [本仓库自审](../../docs/evidence/2026-11-17-repo-self-audit.md) |
| [documents/](documents/) | 10 | [01 · 该有什么文档](../../guide/01-该有什么文档.zh-CN.md) | [十仓采样](../../docs/evidence/2026-11-17-repo-sampling.md) |
| [layout/](layout/) | 8 | [02 · 目录结构](../../guide/02-目录结构.zh-CN.md) | [十仓采样](../../docs/evidence/2026-11-17-repo-sampling.md) · [agent 指令采样](../../docs/evidence/2026-11-18-agent-docs-sampling.md) |
| [writing/](writing/) | 9 | [03 · 文档该怎么写](../../guide/03-文档该怎么写.zh-CN.md) | 写法判据，无实测条目 |
| [agent-config/](agent-config/) | 6 | [04 · Agent 怎么用](../../guide/04-Agent怎么用.zh-CN.md) | [Claude Code 文档摘录](../../docs/evidence/2026-11-17-claude-code-docs.md) |
| [governance/](governance/) | 8 | [05 · Agent 参与怎么管理](../../guide/05-Agent参与怎么管理.zh-CN.md) | [分支保护实测](../../docs/evidence/2026-11-17-protection-probe.md) |
| [release/](release/) | 8 | [06 · 信息该放哪](../../guide/06-信息该放哪.zh-CN.md) | [本仓库自审](../../docs/evidence/2026-11-17-repo-self-audit.md) |
| [settings/](settings/) | 5 | [07 · 该开哪些设置](../../guide/07-该开哪些设置.zh-CN.md) | [分支保护实测](../../docs/evidence/2026-11-17-protection-probe.md) |

合计 **55 条**，8 个板块，`specVersion 2.0.0`。

## L0 · 任何仓库的底线（5 条）

| 旧号 | 规则 | 级别 | 判据 |
|---|---|---|---|
| `R001` | [`documents/readme`](documents/essentials.md) | `must` | 存在 README |
| `R002` | [`documents/agents-md`](documents/essentials.md) | `must` | 根目录存在 AGENTS.md |
| `R003` | [`layout/gitignore`](layout/root-files.md) | `must` | 存在 .gitignore |
| `R004` | [`documents/license`](documents/essentials.md) | `must` | 存在 LICENSE |
| `R005` | [`settings/ci-exists`](settings/ci.md) | `should` | 有 CI 工作流 |

## L1 · 有人在协作（7 条）

| 旧号 | 规则 | 级别 | 判据 |
|---|---|---|---|
| `R010` | [`documents/contributing`](documents/collaboration.md) | `may` | 存在 CONTRIBUTING（人类读者） |
| `R011` | [`documents/codeowners`](documents/collaboration.md) | `should` | 存在 CODEOWNERS |
| `R012` | [`documents/pr-template`](documents/collaboration.md) | `should` | 存在 PR 模板 |
| `R013` | [`documents/issue-template`](documents/collaboration.md) | `should` | Issue 模板带合法 frontmatter |
| `R014` | [`release/changelog`](release/artifact.md) | `should` | 存在 CHANGELOG |
| `R015` | [`layout/editorconfig`](layout/root-files.md) | `may` | 存在 .editorconfig |
| `R016` | [`layout/gitattributes`](layout/root-files.md) | `may` | 存在 .gitattributes（Windows 协作必查） |

## L2 · 有外部使用者（19 条）

| 旧号 | 规则 | 级别 | 判据 |
|---|---|---|---|
| `R020` | [`documents/security`](documents/trust.md) | `should` | 存在 SECURITY.md |
| `R021` | [`documents/code-of-conduct`](documents/trust.md) | `may` | 存在 CODE_OF_CONDUCT |
| `R022` | [`layout/docs-index`](layout/docs-tree.md) | `should` | 存在 docs/index.md 文档地图 |
| `R023` | [`writing/adr-exists`](writing/adr.md) | `should` | 至少有一条 ADR |
| `R024` | [`layout/claude-settings`](layout/agent-files.md) | `should` | 若用 Claude Code：存在 .claude/settings.json |
| `R025` | [`layout/no-settings-local`](layout/agent-files.md) | `must` | settings.local.json 未被提交 |
| `R026` | [`agent-config/permissions-deny`](agent-config/permissions.md) | `should` | 若用 Claude Code：permissions.deny 非空 |
| `R027` | [`documents/license-not-placeholder`](documents/essentials.md) | `may` | LICENSE 不是占位文本 |
| `R028` | [`governance/commit-lint-carrier`](governance/commits.md) | `may` | 提交规范有机器执行载体（可选升级） |
| `R029` | [`governance/commit-attribution`](governance/commits.md) | `should` | 保留 agent 提交归属（未关闭 attribution，与工具无关） |
| `R060` | [`settings/main-protection`](settings/branch-protection.md) | `should` | `main` 受保护：必须 PR + 必需检查 + 禁止删除与强推，且对 admin 也生效 |
| `R061` | [`settings/workflow-permissions`](settings/ci.md) | `should` | workflow 显式声明 `permissions`，第三方 Action 固定到 commit SHA |
| `R062` | [`governance/credentials`](governance/ownership.md) | `should` | agent 使用的凭证是最小权限，且不落盘 |
| `R063` | [`adoption/record`](adoption/record.md) | `should` | 采用记录存在于被管理的那个仓库内 |
| `R064` | [`release/tag-and-release`](release/artifact.md) | `should` | 每个发布版本都有 tag 和 Release 页，tag 锚在发布提交上 |
| `R065` | [`release/notes-sections`](release/content.md) | `should` | Release 正文含四节：升级注意 / 新增·变更·修复 / 已知问题 / 校验 |
| `R066` | [`release/no-stale-numbers`](release/content.md) | `should` | Release 与 CHANGELOG 里不写会失效的计数和状态句 |
| `R067` | [`release/moving-tags`](release/artifact.md) | `should` | 移动 tag 要留痕（旧 SHA / 新 SHA / 原因），且优先发更正版本 |
| `R070` | [`release/version-bump-why`](release/version.md) | `should` | 版本号变更要写明升了哪一位、为什么 |

## L3 · 有 agent 参与开发（24 条）

| 旧号 | 规则 | 级别 | 判据 |
|---|---|---|---|
| `R030` | [`writing/agents-md-length`](writing/agents-md.md) | `should` | AGENTS.md 不超过 200 行 |
| `R031` | [`writing/agents-md-commands`](writing/agents-md.md) | `should` | AGENTS.md 含“命令”一节 |
| `R032` | [`writing/agents-md-boundaries`](writing/agents-md.md) | `should` | AGENTS.md 含“禁区”一节 |
| `R033` | [`agent-config/claude-md-thin`](agent-config/surfaces.md) | `should` | 若用 Claude Code：CLAUDE.md 是薄适配层 |
| `R034` | [`agent-config/hooks-scripts`](agent-config/hooks-skills.md) | `should` | 若配了 hooks：hooks 引用的脚本存在 |
| `R035` | [`agent-config/skill-metadata`](agent-config/hooks-skills.md) | `should` | 若用 skill：skill 带 name 与 description |
| `R036` | [`layout/ignore-agent-personal`](layout/agent-files.md) | `must` | .gitignore 排除个人 agent 配置 |
| `R037` | [`writing/agents-md-paths`](writing/agents-md.md) | `should` | AGENTS.md 引用的路径都存在 |
| `R038` | [`writing/adr-naming`](writing/adr.md) | `may` | ADR 文件名符合 NNNN- 规则 |
| `R039` | [`writing/pr-template-checklist`](writing/pr-template.md) | `may` | PR 模板含自检清单 |
| `R040` | [`agent-config/hook-exit-2`](agent-config/permissions.md) | `may` | 若用 hooks：hook 脚本使用 exit 2 阻塞 |
| `R041` | [`governance/commit-convention`](governance/commits.md) | `may` | 仓库自己的提交约定写进 AGENTS.md |
| `R042` | [`writing/agents-md-language`](writing/agents-md.md) | `may` | AGENTS.md 声明输出语言 |
| `R043` | [`settings/required-check-names`](settings/branch-protection.md) | `should` | 必需检查的名字与 workflow 的 job 名逐字一致 |
| `R044` | [`governance/owner`](governance/ownership.md) | `should` | 治理面有独立 owner，且 agent 不能自行修改 |
| `R045` | [`writing/untrusted-inputs`](writing/untrusted-inputs.md) | `should` | `AGENTS.md` 声明哪些来源是不可信输入，且不得因仓库内容放宽禁区 |
| `R046` | [`agent-config/copilot-instructions`](agent-config/surfaces.md) | `may` | 若用 Copilot：仓库级指令文件存在，且不与 `AGENTS.md` 双写 |
| `R047` | [`layout/assets-location`](layout/docs-tree.md) | `may` | 跨工具 agent 资产放 `.github/`，工具独占的放工具目录，且只有一处事实源 |
| `R048` | [`governance/pr-declaration`](governance/pull-requests.md) | `may` | PR 层面声明 agent 参与（工具 / 是否人工复核） |
| `R049` | [`governance/revertable`](governance/pull-requests.md) | `may` | agent 的改动可单独 revert |
| `R050` | [`governance/conventional-subject`](governance/commits.md) | `may` | 最近提交的 subject 符合 Conventional Commits |
| `R051` | [`settings/linear-history`](settings/branch-protection.md) | `may` | 最近提交是线性历史（无 merge commit） |
| `R068` | [`release/superseded-tags`](release/artifact.md) | `may` | 废弃 tag 标 *Superseded* 并指向替代 tag，不删 tag |
| `R069` | [`release/self-noncompliance`](release/content.md) | `may` | 规范类项目的 Release 在「已知问题」里列出自己不合格的条目 |

---

**2.0.0 之后剩下的不对称**（写在这里，不让读者自己去发现）：


- **已经补上的**：00 章的采用记录（`R063`）、05 与 07 章论证的门禁（`R060`、`R043`、`R044`、`R049`）——1.5.0 补齐，
  决策与代价见 [ADR-0011](../../docs/adr/0011-github-management-rules.md)；06 章 §2 的发布规矩（`R064`–`R070`）——1.6.0 补齐，
  见 [ADR-0012](../../docs/adr/0012-release-notes-spec.md)。
- **1.6.0 这批是反过来的**：06 章 §2 早就把"什么时候发、Release 怎么写、tag 能不能移动"写完了，清单里却**一条都没有**。
  前面几批是"有条目没章节"，这批是"有章节没条目"——同一种漂移的两个方向。
  `R070` 是同一处的第三例：SemVer 策略写在 [README.md](../README.md)「版本策略」里，清单引用数同样是 0。
- **仍然有条目没章节**：`R045`（不可信输入）与 `R061`（Actions 供应链）**全库没有一节正面讲**，只有清单里的一行判据；
  `R050` / `R051` 也只在 05 与 07 的末尾顺带出现。
- **2.0.0 换了 ID 但 `guide/` 正文没跟着换**：八章里还有 365 处写的是旧号 `R0xx`，
  含 19 处区间写法（`R064`–`R070` 这种）不能机械替换。它们**继续有效**——本表第一列就是旧号。
  要不要做正文改名，见 [ADR-0013](../../docs/adr/0013-rules-by-domain.md)「未解决」。
- **板块规模不均**：`documents/` 10 条 vs `adoption/` 1 条。不掩盖，上面那张表就写着条数。
- **新条目都还没有经过外部仓库实测**：`R043`–`R049`、`R060`–`R069` 的判据来自平台文档、本库事故与既有采样，
  下一批采样要专门验证它们是否真的可判定。


