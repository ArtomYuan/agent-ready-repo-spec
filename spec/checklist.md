# 自查清单

> 本文件是本规范**唯一的事实源**，共 37 条（specVersion 1.4.0）。
> 级别含义：`must` 缺了就是问题；`should` 强烈建议；`may` 视情况。
> 用法：把这张表当成对照表，逐条问"我们有吗 / 什么理由没有"，**理由比勾选更重要**。
> 机器可读的历史版本（JSON + 检查器）已在 ADR-0009 中下线：规范库不提供可执行物，也不绑定任何语言。
>
> **编号按档位分段预留**：`R001`–`R009`=L0、`R010`–`R019`=L1、`R020`–`R029`=L2、`R030`–`R049`=L3、`R050` 起=需要看 `git log`。
> 所以 `R006`–`R009`、`R017`–`R019`、`R043`–`R049` 不出现是**预留**，不是缺条。号段与"永不复用"的规则见 [README.md](README.md)。
>
> **怎么才算"符合"**：见 [README.md](README.md) 的「符合性声明」——全部 `must` 满足 + 每个偏离的 `should` 有书面理由
> + 采用记录落在你自己的仓库里。`may` 不影响符合性。

## 章节索引

只做导航：**判据只在下面的分级表里，本表不含任何判定**。每章末尾有反向的「本章对应的自查项」。

| 章节 | 这一章解释的条目 | 主要证据 |
|---|---|---|
| [00 · 接入决策](../guide/00-接入决策.zh-CN.md) | **（无——见下方缺口）** | [本仓库自审](../docs/evidence/2026-11-17-repo-self-audit.md) |
| [01 · 该有什么文档](../guide/01-该有什么文档.zh-CN.md) | `R001` `R002` `R004` `R010` `R013` `R020` `R021` `R027` | [十仓采样](../docs/evidence/2026-11-17-repo-sampling.md) |
| [02 · 目录结构](../guide/02-目录结构.zh-CN.md) | `R003` `R013` `R015` `R016` `R022` `R024` `R025` `R030` `R033` `R036` | [十仓采样](../docs/evidence/2026-11-17-repo-sampling.md) · [agent 指令采样](../docs/evidence/2026-11-18-agent-docs-sampling.md) |
| [03 · 文档该怎么写](../guide/03-文档该怎么写.zh-CN.md) | `R001` `R002` `R010` `R011` `R012` `R014` `R020` `R022` `R023` `R027` `R030`–`R033` `R037` `R038` `R039` `R041` `R042` | 写法判据，无实测条目 |
| [04 · Agent 怎么用](../guide/04-Agent怎么用.zh-CN.md) | `R005` `R024` `R026` `R030` `R031` `R032` `R034` `R035` `R040` | [Claude Code 文档摘录](../docs/evidence/2026-11-17-claude-code-docs.md) |
| [05 · Agent 参与怎么管理](../guide/05-Agent参与怎么管理.zh-CN.md) | `R011` `R029` `R041` `R050` | [分支保护实测](../docs/evidence/2026-11-17-protection-probe.md) |
| [06 · 信息该放哪](../guide/06-信息该放哪.zh-CN.md) | `R014` `R023` `R028` `R050` | [本仓库自审](../docs/evidence/2026-11-17-repo-self-audit.md) |
| [07 · 该开哪些设置](../guide/07-该开哪些设置.zh-CN.md) | `R005` `R051` | [分支保护实测](../docs/evidence/2026-11-17-protection-probe.md) |

**两个已知的不对称**——写在这里，不让读者自己去发现：

- **有章节没条目**：00 章的"采用记录"、05 与 07 章论证的门禁（必须 PR、必需检查、禁止 admin 绕过、回滚路径）
  都是可判定的结构性事实，清单里却没有对应条目。07 章末尾把这件事直称为"本库最大的覆盖缺口"。
- **有条目没章节**：`R050` / `R051` 只在 05 与 07 的末尾顺带出现，没有一节正面讲"提交历史怎么算合格"。

---

## L0 · 任何仓库的底线

| id | 级别 | 条目 | 为什么 | 怎么改 |
|---|---|---|---|---|
| `R001` | must | 存在 README | GitHub 按 .github/ > 根 > docs/ 的顺序取第一个 README 作为仓库首页；没有它，仓库等于不可评估。 | 写 README.md：一句话定位 + 30 秒能跑起来的最小命令 + 入口链接。 |
| `R002` | must | 根目录存在 AGENTS.md | AGENTS.md 是跨工具的 agent 唯一事实源；Claude Code 在无 CLAUDE.md 时默认直接读它。 | 在根目录建 AGENTS.md。八段骨架见 [guide/03 §2](../guide/03-文档该怎么写.zh-CN.md)：项目是什么 / 语言约定 / 命令 / 目录地图 / 硬约定 / 禁区 / 已知的坑 / 拿不准时。可直接粘：[templates/AGENTS.md.tmpl](../templates/AGENTS.md.tmpl)。 |
| `R003` | must | 存在 .gitignore | 没有 .gitignore 的仓库迟早把构建产物和密钥提交进来。 | 加 .gitignore，至少覆盖依赖目录、构建产物、.env*。 |
| `R004` | must | 存在 LICENSE | 无协议等于默认保留全部权利，别人无法合法使用。 | 选一个 OSI 协议（MIT / Apache-2.0）放进根目录，并写进 README。 |
| `R005` | should | 有 CI 工作流 | 没有 CI，agent 的改动就没有可拒绝的依据。 | 加 .github/workflows/ci.yml，至少跑 lint + test。 |

## L1 · 有人在协作

| id | 级别 | 条目 | 为什么 | 怎么改 |
|---|---|---|---|---|
| `R010` | may | 存在 CONTRIBUTING（人类读者） | 这份文件是写给人看的：agent 不会自动加载它（Claude Code 的加载链里没有 CONTRIBUTING），GitHub 也只认固定位置的入口文件（根 / .github / docs，文件名大小写不敏感，.rst 也认，`contributing/` 目录本身不算）。所以它是公开库的常见习惯，不是 agent 就绪的必要条件。 | 在根或 .github/ 放一个 CONTRIBUTING.md 作入口，详细内容放 docs/ 或 contributing/ 目录并在入口里指过去；私有库且不收外部 PR 可以不管。 |
| `R011` | should | 存在 CODEOWNERS | 按路径自动指派评审人，是 agent 改动的第一道人工闸门；需同时开启 Require review from Code Owners。 | 加 CODEOWNERS，覆盖 .claude/、.github/workflows/、AGENTS.md 与关键业务目录。 |
| `R012` | should | 存在 PR 模板 | 模板是唯一能稳定拿到的结构化信息（改了什么/为什么/怎么验证的）。 | 加 .github/PULL_REQUEST_TEMPLATE.md，含改动、理由、影响面、验证输出、自检清单。 |
| `R013` | should | Issue 模板带合法 frontmatter | 只有 .github/ISSUE_TEMPLATE/ 下带 name + description（或 name + about）的模板才会被社区档案打勾。 | 给每个 .yml 模板补 name: 与 description:；.md 模板用 name + about。 |
| `R014` | should | 存在 CHANGELOG | CHANGELOG 是 agent 判断“这个 API 还能不能用”的第一手依据，也是行为契约。 | 按 Keep a Changelog 建 CHANGELOG.md，只写用户可感知的行为变化。 |
| `R015` | may | 存在 .editorconfig | 跨编辑器统一缩进与行尾，减少 agent 与人的格式噪音。 | 加 .editorconfig，声明缩进、行尾、字符集。 |
| `R016` | may | 存在 .gitattributes（Windows 协作必查） | 不处理行尾与二进制/LFS，跨平台协作会产生整文件 diff 与损坏的二进制。 | 加 .gitattributes：* text=auto eol=lf，图片/字体标 binary。 |

## L2 · 有外部使用者

| id | 级别 | 条目 | 为什么 | 怎么改 |
|---|---|---|---|---|
| `R020` | should | 存在 SECURITY.md | 有对外暴露面的仓库，SECURITY.md 才能开启私密漏洞上报，避免漏洞进公开 issue。 | 写 SECURITY.md：支持版本、私密上报通道、响应时限。 |
| `R021` | may | 存在 CODE_OF_CONDUCT | 对外协作的项目需要明确社区行为标准与举报路径。 | 添加 Contributor Covenant 或等价文本。 |
| `R022` | should | 存在 docs/index.md 文档地图 | 没有地图，人和 agent 都靠猜；猜的成本最终落在 review 上。 | 建 docs/index.md，按 教程/参考/架构/ADR/运维 五类给出入口。 |
| `R023` | should | 至少有一条 ADR | 没有 ADR，agent 会每隔几个月把同一批设计重做一遍——它只看到现状，看不到为什么不是另一种。 | 建 docs/adr/0001-<slug>.md：背景 / 选项 / 结论 / 后果。 |
| `R024` | should | **若用 Claude Code**：存在 .claude/settings.json | 团队共享的权限与 hooks 必须进版本库，否则每个人的门禁都不一样。 | 加 .claude/settings.json：permissions.deny 优先，hooks 只放声明式表达不了的事。 |
| `R025` | must | settings.local.json 未被提交 | 个人覆盖含本机路径与令牌，提交即泄露。 | 从索引移除：git rm --cached .claude/settings.local.json，并写进 .gitignore。 |
| `R026` | should | **若用 Claude Code**：permissions.deny 非空 | 没有 deny 就是全开；密钥路径与破坏性命令必须先封。 | 至少 deny：Read(./.env)、Read(./secrets/**)、Bash(rm *)、Bash(git reset *)。 |
| `R027` | may | LICENSE 不是占位文本 | 占位 LICENSE 在法律上等于没有协议。 | 填入真实年份与著作权人。 |
| `R028` | may | 提交规范有机器执行载体（可选升级） | GitHub 自家仓库大多不强制提交格式（actions/checkout 只在 CONTRIBUTING 里给一条外部链接），Claude Code 也不内置格式校验——所以这条不是行业基线，而是**可选升级**：只有当你希望按前缀自动生成 CHANGELOG / 自动发版时才需要它。 | 加 commitlint 配置（extends @commitlint/config-conventional），并在 CI 或 commit-msg hook 里跑起来；不需要自动化的仓库可以不管这条。 |
| `R029` | should | 保留 agent 提交归属（未关闭 attribution，与工具无关） | Claude Code 默认给提交加 git trailer（`Co-Authored-By: <model> <noreply@anthropic.com>`），这是 agent 参与最便宜的审计手段；把它关掉，事后就分不清哪次提交是模型写的。 | 删掉 attribution 的 false / 空字符串；要改文案就保留 trailer，例如 `attribution.commit: "Co-Authored-By: Claude <noreply@anthropic.com>"`。 |

## L3 · 有 agent 参与开发

| id | 级别 | 条目 | 为什么 | 怎么改 |
|---|---|---|---|---|
| `R030` | should | AGENTS.md 不超过 200 行 | 每次会话都全文加载；超过 200 行内容变贵且遵守率下降。 | 把模块级规则移到 .claude/rules/（带 paths），把多步流程移到 skill。 |
| `R031` | should | AGENTS.md 含“命令”一节 | 命令是 agent 最依赖、最容易被旧记忆污染的信息，必须有唯一权威。 | 在 AGENTS.md 加“## 命令（唯一权威）”，列安装/开发/测试/检查。 |
| `R032` | should | AGENTS.md 含“禁区”一节 | 禁区不写清楚，agent 只能靠猜边界；写清楚后还能被 hooks/CI 对应上。 | 加“## 禁区（由 hooks 强制）”，列受保护路径与破坏性命令。 |
| `R033` | should | **若用 Claude Code**：CLAUDE.md 是薄适配层 | CLAUDE.md 与 AGENTS.md 各写一份会形成双事实源，agent 随机选一个生效。 | CLAUDE.md 第一行写 @AGENTS.md，只保留 Claude 专属的少量补充。 |
| `R034` | should | **若配了 hooks**：hooks 引用的脚本存在 | hook 指向不存在的脚本时，门禁静默失效，比没有 hook 更危险。 | 修正路径，或删除该 hook；改动后故意触发一次确认拦住。 |
| `R035` | should | **若用 skill**：skill 带 name 与 description | description 是 skill 被自动命中的唯一依据，缺了就只能靠人记得输入命令。 | 补 frontmatter：name（短横线）、description（写清何时使用）。 |
| `R036` | must | .gitignore 排除个人 agent 配置 | 只靠自觉不提交会失败；必须在 .gitignore 里写死。 | 在 .gitignore 加 .claude/settings.local.json 与 CLAUDE.local.md。 |
| `R037` | should | AGENTS.md 引用的路径都存在 | 文档腐烂最常见形态：重构后路径全失效，agent 照着不存在的路径干活。 | 修正或删除失效引用；在 CI 里常驻本检查。 |
| `R038` | may | ADR 文件名符合 NNNN- 规则 | 编号是 ADR 的引用锚点，命名不一致就无法交叉引用。 | 重命名为 0001-lowercase-slug.md，永不删除，只标 Superseded。 |
| `R039` | may | PR 模板含自检清单 | 自检清单把“agent 该确认的事”变成可勾选项，比散文有效。 | 在模板加 - [ ] 项：未触碰禁区、已更新 CHANGELOG、已补 ADR。 |
| `R040` | may | **若用 hooks**：hook 脚本使用 exit 2 阻塞 | 阻塞类 hook 不收 exit 2 就等于没检查：exit 0 只进日志，exit 1 是非阻塞错误。 | 违规分支改为写 stderr 后 exit 2。 |
| `R041` | may | 仓库自己的提交约定写进 AGENTS.md | Claude Code 默认自带一套提交/PR 指令（includeGitInstructions=true）。仓库若另有约定，必须写进 AGENTS.md，否则两套指令打架；要么在这里声明，要么把内置指令关掉（includeGitInstructions=false）。 | 在 AGENTS.md 的“硬约定”里写一行提交约定；若关闭了内置指令，则必须写清楚完整规则。 |
| `R042` | may | AGENTS.md 声明输出语言 | agent 的语言默认跟着代码注释或它上次的输出来走，没人声明就会在同一仓库里出现两种语言，reviewer 反复纠正。声明一次的成本最低。**没有真实事故支撑，故停在 may。** | 在 AGENTS.md 靠前位置加「语言约定」：使用语言、不翻译清单（规则 ID / 路径 / 命令 / 代码标识符）、译文与原文冲突时以原文为准。可直接粘的片段见 `templates/prompt-locale.md.tmpl`。 |
| `R050` | may | 最近提交的 subject 符合 Conventional Commits | 格式只在文档里 = 不生效。history 是唯一无法事后伪造的证据：subject 能解析，CHANGELOG 与 release 才能自动化。 | 把不合规的 subject 在后续提交里改正并说明；长期方案是让 commitlint 在 CI/hook 上拦住新提交（R028）。 |
| `R051` | may | 最近提交是线性历史（无 merge commit） | 线性历史让 revert、cherry-pick、审计都变简单；merge commit 会把一条 PR 的变化混进两条父提交，出问题时难以定位与回滚。 | 仓库设置启用 Squash merge 或 Rebase merge，关闭 Merge commit；已存在的 merge 不必重写。 |

---

## 判完一条之后

每条只有三种结论：**已有** / **建议补** / **跳过 + 理由**。

第三种最有价值——它让下一个人（或下一个 agent）不会把"没有"读成"漏了"，从而"顺手帮你补上"。
理由写进采用记录，落点在你自己的仓库里：[templates/adoption.md.tmpl](../templates/adoption.md.tmpl)。
