# 规则表

> 由 `rules/rules.json` 自动生成，**请勿手改**。规范版本 `1.3.0`。
> 重新生成：`pwsh ./checker/gen-rules-doc.ps1`

共 **36** 条规则。严重度 `must` / `should` / `may`；`may` 不阻断达成等级。

| 级别 | 含义 | 规则数 |
|---|---|---|
| L0 | 能被人和 agent 读懂并跑起来 | 5 |
| L1 | 能接受第三方贡献且不被打断 | 7 |
| L2 | 能对外、能生产、决策可追溯 | 10 |
| L3 | agent 提交占多数时的治理与防腐 | 14 |

## L0 · 能被人和 agent 读懂并跑起来

| ID | 严重度 | 要求 | 判定 |
|---|---|---|---|
| `R001` | must | 存在 README | kind: `file-exists` · any=README.md, .github/README.md, docs/README.md · nonEmpty=True |
| `R002` | must | 根目录存在 AGENTS.md | kind: `file-exists` · any=AGENTS.md · nonEmpty=True |
| `R003` | must | 存在 .gitignore | kind: `file-exists` · any=.gitignore · nonEmpty=True |
| `R004` | must | 存在 LICENSE | kind: `file-exists` · any=LICENSE, LICENSE.md, LICENSE.txt, COPYING · nonEmpty=True |
| `R005` | should | 有 CI 工作流 | kind: `dir-min-files` · dir=.github/workflows · pattern=*.yml · min=1 |

<details><summary>为什么 / 怎么改</summary>

- **R001** GitHub 按 .github/ > 根 > docs/ 的顺序取第一个 README 作为仓库首页；没有它，仓库等于不可评估。
  - 修复：写 README.md：一句话定位 + 30 秒能跑起来的最小命令 + 入口链接。
- **R002** AGENTS.md 是跨工具的 agent 唯一事实源；Claude Code 在无 CLAUDE.md 时默认直接读它。
  - 修复：在根目录建 AGENTS.md，只写命令、目录地图、硬约定、禁区、已知的坑。
- **R003** 没有 .gitignore 的仓库迟早把构建产物和密钥提交进来。
  - 修复：加 .gitignore，至少覆盖依赖目录、构建产物、.env*。
- **R004** 无协议等于默认保留全部权利，别人无法合法使用。
  - 修复：选一个 OSI 协议（MIT / Apache-2.0）放进根目录，并写进 README。
- **R005** 没有 CI，agent 的改动就没有可拒绝的依据。
  - 修复：加 .github/workflows/ci.yml，至少跑 lint + test。

</details>

## L1 · 能接受第三方贡献且不被打断

| ID | 严重度 | 要求 | 判定 |
|---|---|---|---|
| `R010` | may | 存在 CONTRIBUTING（人类读者） | kind: `file-exists` · any=CONTRIBUTING.md, .github/CONTRIBUTING.md, docs/CONTRIBUTING.md · nonEmpty=True |
| `R011` | should | 存在 CODEOWNERS | kind: `file-exists` · any=.github/CODEOWNERS, CODEOWNERS, docs/CODEOWNERS · nonEmpty=True |
| `R012` | should | 存在 PR 模板 | kind: `file-exists` · any=.github/PULL_REQUEST_TEMPLATE.md, PULL_REQUEST_TEMPLATE.md, .github/pull_request_template.md · nonEmpty=True |
| `R013` | should | Issue 模板带合法 frontmatter | kind: `frontmatter-fields` · dir=.github/ISSUE_TEMPLATE · pattern=*.yml · exclude=config.yml · fields=name · fieldsOneOf=(description|about) |
| `R014` | should | 存在 CHANGELOG | kind: `file-exists` · any=CHANGELOG.md, CHANGES.md, HISTORY.md · nonEmpty=True |
| `R015` | may | 存在 .editorconfig | kind: `file-exists` · any=.editorconfig · nonEmpty=True |
| `R016` | may | 存在 .gitattributes（Windows 协作必查） | kind: `file-exists` · any=.gitattributes · nonEmpty=True |

<details><summary>为什么 / 怎么改</summary>

- **R010** 这份文件是写给人看的：agent 不会自动加载它（Claude Code 的加载链里没有 CONTRIBUTING），GitHub 也只认固定位置的入口文件（根 / .github / docs，文件名大小写不敏感，.rst 也认，`contributing/` 目录本身不算）。所以它是公开库的常见习惯，不是 agent 就绪的必要条件。
  - 修复：在根或 .github/ 放一个 CONTRIBUTING.md 作入口，详细内容放 docs/ 或 contributing/ 目录并在入口里指过去；私有库且不收外部 PR 可以不管。
- **R011** 按路径自动指派评审人，是 agent 改动的第一道人工闸门；需同时开启 Require review from Code Owners。
  - 修复：加 CODEOWNERS，覆盖 .claude/、.github/workflows/、AGENTS.md 与关键业务目录。
- **R012** 模板是唯一能稳定拿到的结构化信息（改了什么/为什么/怎么验证的）。
  - 修复：加 .github/PULL_REQUEST_TEMPLATE.md，含改动、理由、影响面、验证输出、自检清单。
- **R013** 只有 .github/ISSUE_TEMPLATE/ 下带 name + description（或 name + about）的模板才会被社区档案打勾。
  - 修复：给每个 .yml 模板补 name: 与 description:；.md 模板用 name + about。
- **R014** CHANGELOG 是 agent 判断“这个 API 还能不能用”的第一手依据，也是行为契约。
  - 修复：按 Keep a Changelog 建 CHANGELOG.md，只写用户可感知的行为变化。
- **R015** 跨编辑器统一缩进与行尾，减少 agent 与人的格式噪音。
  - 修复：加 .editorconfig，声明缩进、行尾、字符集。
- **R016** 不处理行尾与二进制/LFS，跨平台协作会产生整文件 diff 与损坏的二进制。
  - 修复：加 .gitattributes：* text=auto eol=lf，图片/字体标 binary。

</details>

## L2 · 能对外、能生产、决策可追溯

| ID | 严重度 | 要求 | 判定 |
|---|---|---|---|
| `R020` | should | 存在 SECURITY.md | kind: `file-exists` · any=SECURITY.md, .github/SECURITY.md, docs/SECURITY.md · nonEmpty=True |
| `R021` | may | 存在 CODE_OF_CONDUCT | kind: `file-exists` · any=CODE_OF_CONDUCT.md, .github/CODE_OF_CONDUCT.md, docs/CODE_OF_CONDUCT.md · nonEmpty=True |
| `R022` | should | 存在 docs/index.md 文档地图 | kind: `file-exists` · any=docs/index.md, docs/README.md · nonEmpty=True |
| `R023` | should | 至少有一条 ADR | kind: `dir-min-files` · dir=docs/adr · pattern=*.md · min=1 |
| `R024` | should | 存在 .claude/settings.json | kind: `file-exists` · any=.claude/settings.json · nonEmpty=True |
| `R025` | must | settings.local.json 未被提交 | kind: `file-absent` · any=.claude/settings.local.json |
| `R026` | should | permissions.deny 非空 | kind: `json-nonempty` · file=.claude/settings.json · path=permissions.deny |
| `R027` | may | LICENSE 不是占位文本 | kind: `file-not-contains` · file=LICENSE · regex=<name of author>|<owner>|TODO|Placeholder |
| `R028` | may | 提交规范有机器执行载体（可选升级） | kind: `file-exists` · any=commitlint.config.js, commitlint.config.cjs, commitlint.config.mjs, commitlint.config.json, .commitlintrc, .commitlintrc.json, .commitlintrc.yml, .commitlintrc.yaml, .commitlintrc.js, .commitlintrc.cjs |
| `R029` | should | 保留 agent 提交归属（未关闭 attribution） | kind: `json-forbid` · file=.claude/settings.json · checks=,  |

<details><summary>为什么 / 怎么改</summary>

- **R020** 有对外暴露面的仓库，SECURITY.md 才能开启私密漏洞上报，避免漏洞进公开 issue。
  - 修复：写 SECURITY.md：支持版本、私密上报通道、响应时限。
- **R021** 对外协作的项目需要明确社区行为标准与举报路径。
  - 修复：添加 Contributor Covenant 或等价文本。
- **R022** 没有地图，人和 agent 都靠猜；猜的成本最终落在 review 上。
  - 修复：建 docs/index.md，按 教程/参考/架构/ADR/运维 五类给出入口。
- **R023** 没有 ADR，agent 会每隔几个月把同一批设计重做一遍——它只看到现状，看不到为什么不是另一种。
  - 修复：建 docs/adr/0001-<slug>.md：背景 / 选项 / 结论 / 后果。
- **R024** 团队共享的权限与 hooks 必须进版本库，否则每个人的门禁都不一样。
  - 修复：加 .claude/settings.json：permissions.deny 优先，hooks 只放声明式表达不了的事。
- **R025** 个人覆盖含本机路径与令牌，提交即泄露。
  - 修复：从索引移除：git rm --cached .claude/settings.local.json，并写进 .gitignore。
- **R026** 没有 deny 就是全开；密钥路径与破坏性命令必须先封。
  - 修复：至少 deny：Read(./.env)、Read(./secrets/**)、Bash(rm *)、Bash(git reset *)。
- **R027** 占位 LICENSE 在法律上等于没有协议。
  - 修复：填入真实年份与著作权人。
- **R028** GitHub 自家仓库大多不强制提交格式（actions/checkout 只在 CONTRIBUTING 里给一条外部链接），Claude Code 也不内置格式校验——所以这条不是行业基线，而是**可选升级**：只有当你希望按前缀自动生成 CHANGELOG / 自动发版时才需要它。
  - 修复：加 commitlint 配置（extends @commitlint/config-conventional），并在 CI 或 commit-msg hook 里跑起来；不需要自动化的仓库可以不管这条。
- **R029** Claude Code 默认给提交加 git trailer（`Co-Authored-By: <model> <noreply@anthropic.com>`），这是 agent 参与最便宜的审计手段；把它关掉，事后就分不清哪次提交是模型写的。
  - 修复：删掉 attribution 的 false / 空字符串；要改文案就保留 trailer，例如 `attribution.commit: "Co-Authored-By: Claude <noreply@anthropic.com>"`。

</details>

## L3 · agent 提交占多数时的治理与防腐

| ID | 严重度 | 要求 | 判定 |
|---|---|---|---|
| `R030` | should | AGENTS.md 不超过 200 行 | kind: `file-max-lines` · file=AGENTS.md · max=200 |
| `R031` | should | AGENTS.md 含“命令”一节 | kind: `file-contains` · file=AGENTS.md · regex=^#{1,4}\s*(.+)?(命令|Commands|命令行) |
| `R032` | should | AGENTS.md 含“禁区”一节 | kind: `file-contains` · file=AGENTS.md · regex=^#{1,4}\s*(.+)?(禁区|禁止|Forbidden|Prohibited) |
| `R033` | should | CLAUDE.md 是薄适配层 | kind: `file-limit` · file=CLAUDE.md · regex=@AGENTS\.md · max=40 |
| `R034` | should | hooks 引用的脚本存在 | kind: `json-hook-scripts-exist` · file=.claude/settings.json |
| `R035` | should | skill 带 name 与 description | kind: `frontmatter-fields` · dir=.claude/skills · pattern=SKILL.md · fields=name, description |
| `R036` | must | .gitignore 排除个人 agent 配置 | kind: `file-contains` · file=.gitignore · regex=settings\.local\.json |
| `R037` | should | AGENTS.md 引用的路径都存在 | kind: `md-refs-exist` · file=AGENTS.md · ignore=.claude/settings.local.json, CLAUDE.local.md, package.json, requirements.txt |
| `R038` | may | ADR 文件名符合 NNNN- 规则 | kind: `name-pattern` · dir=docs/adr · pattern=*.md · regex=^\d{4}-[a-z0-9-]+\.md$ |
| `R039` | may | PR 模板含自检清单 | kind: `file-contains` · file=.github/PULL_REQUEST_TEMPLATE.md · regex=[-*]\s*\[\s*\] |
| `R040` | may | hook 脚本使用 exit 2 阻塞 | kind: `dir-contains` · dir=.claude/hooks · pattern=*.ps1 · regex=exit\s+2 |
| `R041` | may | 仓库自己的提交约定写进 AGENTS.md | kind: `file-contains` · file=AGENTS.md · regex=(提交信息|提交约定|Commit Message|commit message|Conventional Commits) |
| `R050` | may | 最近提交的 subject 符合 Conventional Commits | kind: `git-commit-subject` · regex=^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .+ · maxLength=72 · depth=50 |
| `R051` | may | 最近提交是线性历史（无 merge commit） | kind: `git-commit-no-merge` · depth=50 |

<details><summary>为什么 / 怎么改</summary>

- **R030** 每次会话都全文加载；超过 200 行内容变贵且遵守率下降。
  - 修复：把模块级规则移到 .claude/rules/（带 paths），把多步流程移到 skill。
- **R031** 命令是 agent 最依赖、最容易被旧记忆污染的信息，必须有唯一权威。
  - 修复：在 AGENTS.md 加“## 命令（唯一权威）”，列安装/开发/测试/检查。
- **R032** 禁区不写清楚，agent 只能靠猜边界；写清楚后还能被 hooks/CI 对应上。
  - 修复：加“## 禁区（由 hooks 强制）”，列受保护路径与破坏性命令。
- **R033** CLAUDE.md 与 AGENTS.md 各写一份会形成双事实源，agent 随机选一个生效。
  - 修复：CLAUDE.md 第一行写 @AGENTS.md，只保留 Claude 专属的少量补充。
- **R034** hook 指向不存在的脚本时，门禁静默失效，比没有 hook 更危险。
  - 修复：修正路径，或删除该 hook；改动后故意触发一次确认拦住。
- **R035** description 是 skill 被自动命中的唯一依据，缺了就只能靠人记得输入命令。
  - 修复：补 frontmatter：name（短横线）、description（写清何时使用）。
- **R036** 只靠自觉不提交会失败；必须在 .gitignore 里写死。
  - 修复：在 .gitignore 加 .claude/settings.local.json 与 CLAUDE.local.md。
- **R037** 文档腐烂最常见形态：重构后路径全失效，agent 照着不存在的路径干活。
  - 修复：修正或删除失效引用；在 CI 里常驻本检查。
- **R038** 编号是 ADR 的引用锚点，命名不一致就无法交叉引用。
  - 修复：重命名为 0001-lowercase-slug.md，永不删除，只标 Superseded。
- **R039** 自检清单把“agent 该确认的事”变成可勾选项，比散文有效。
  - 修复：在模板加 - [ ] 项：未触碰禁区、已更新 CHANGELOG、已补 ADR。
- **R040** 阻塞类 hook 不收 exit 2 就等于没检查：exit 0 只进日志，exit 1 是非阻塞错误。
  - 修复：违规分支改为写 stderr 后 exit 2。
- **R041** Claude Code 默认自带一套提交/PR 指令（includeGitInstructions=true）。仓库若另有约定，必须写进 AGENTS.md，否则两套指令打架；要么在这里声明，要么把内置指令关掉（includeGitInstructions=false）。
  - 修复：在 AGENTS.md 的“硬约定”里写一行提交约定；若关闭了内置指令，则必须写清楚完整规则。
- **R050** 格式只在文档里 = 不生效。history 是唯一无法事后伪造的证据：subject 能解析，CHANGELOG 与 release 才能自动化。
  - 修复：把不合规的 subject 在后续提交里改正并说明；长期方案是让 commitlint 在 CI/hook 上拦住新提交（R028）。
- **R051** 线性历史让 revert、cherry-pick、审计都变简单；merge commit 会把一条 PR 的变化混进两条父提交，出问题时难以定位与回滚。
  - 修复：仓库设置启用 Squash merge 或 Rebase merge，关闭 Merge commit；已存在的 merge 不必重写。

</details>

