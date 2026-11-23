# 提交规则

> 板块 `governance` · 本页承载 4 条条目：`governance/commit-attribution`（L2 · should · 旧 `R029`）·
> `governance/commit-convention`（L3 · may · 旧 `R041`）· `governance/commit-lint-carrier`（L2 · may · 旧 `R028`）·
> `governance/conventional-subject`（L3 · may · 旧 `R050`）
> 讲解与事故见 [guide/05 · Agent 参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)。

## 一句话

提交层只回答两个问题：**这次改动是谁写的**、**机器读不读得懂**。
归属靠 trailer，格式靠约定，而约定靠一个真的会跑起来的东西——**没有执行载体的约定只是愿望**。
本库在 1.4.0 亲手删掉了提交信息的执行载体（`.commitlintrc.json` 与 `提交信息（commitlint）` job），
结果被它留在 ruleset 里的**那个名字**锁死了 `main` 一次：约定删得掉，引用删不掉。

## 四条条目各管一层

| 你想回答的问题 | 条目 | 载体在哪 | 档位 · 级别 |
|---|---|---|---|
| 这次提交是谁写的 | `governance/commit-attribution` | git trailer（`Co-authored-by`） | L2 · should |
| 这个仓库的提交格式是什么 | `governance/commit-convention` | `AGENTS.md` 里的一行 | L3 · may |
| 谁执行这个格式 | `governance/commit-lint-carrier` | commitlint 配置 + CI job 或 commit-msg hook | L2 · may |
| 历史真的按格式走了吗 | `governance/conventional-subject` | `git log` 抽样 | L3 · may |

四行里最容易漏的是第三行。**前两行加起来，正好是一份没人执行的约定**——而前两行都很容易"做完"：
写一行 trailer 配置、在 `AGENTS.md` 里补一句"用 Conventional Commits"，勾就打上了。

## 约定、载体、门禁引用：本库反复出血的那道缝

| 层 | 长什么样 | 缺了会怎样 | 本库现状（2026-11-20 实测） |
|---|---|---|---|
| **约定** | `AGENTS.md`「硬约定」里一行：提交信息用 Conventional Commits，scope 取 `guide` / `spec` / `templates` / `docs` | agent 自带一套提交指令，两套打架、模型随机选一个 | **有** |
| **载体** | `.commitlintrc.json` + 一个真的跑它的 CI job 或 commit-msg hook | 约定只约束"当天记得它的人"，新会话的 agent 第一个破 | **无**（1.4.0 随 [ADR-0009](../../../docs/adr/0009-spec-only-no-tooling.md) 一起删掉） |
| **门禁引用** | ruleset 的 `required_status_checks` 里那个 job 名字符串 | 载体删了、引用还在 → 该项永久 `Expected — Waiting for status to be reported` | 曾有 4 个（含 `提交信息（commitlint）`），[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md) 之后换成 `链接检查` / `双语配对` |

事故过程（全部记录在 ADR-0010，不是假设）：删掉 `.github/workflows/ci.yml` 的 PR #22 打开后，
四个必需检查永远 pending；第一反应是"Actions 额度用完了"，查了配额 `core 4994/5000`、两个新 job 5–7 秒跑完，
**不是额度，是那四个名字根本没有生产者**。改成两个新 job 名之后又踩第二次——ruleset 里写成了
**`双语配队`**（队，码点 38431），而 job 上报的是 **`双语配对`**（对，23545），肉眼完全看不出差别。

从这次事故抽出三条给"要加载体的人"：

1. **载体是双向耦合的**：每加一个 job，就多一处需要人记住的名字。把它加进必需检查之前，
   先看 [分支保护规则](../settings/branch-protection.md) 的改名三步（先加新名 job → 改 ruleset → 下个 PR 删旧 job）。
2. **载体不进必需检查也有价值**：commit-msg hook 在本地就挡住，不产生任何 ruleset 耦合——
   想要格式约束但怕自锁，就走 hook 这条路。
3. **不想要自动化就显式写"不采用"**：本库现在的状态是"约定有、载体无、必需检查里没有提交信息这一项"，
   这是 ADR-0009 的**决定**，不是遗漏；按 [采用记录规则](../adoption/record.md)，决定要落在文件里，
   否则下一个 agent 会把"没有 commitlint"读成"漏了"，顺手加回来。

## 归属线索怎么读、怎么坏

本库 `git log` 实测（`git log --all --format='%an <%ae> %s'`）：

| 观测 | 数值 | 说明 |
|---|---|---|
| `--all` 全部提交 | 59 | 含未合并分支；**截至 `06fe228`**——这个数每个提交都会涨，稳定口径看下一行的 `main` |
| 其中带 `Co-authored-by` 的 | 26 | 约四成半 |
| `main` 上带 trailer 的 | 21 / 44 | 已合并历史里近半（main 未再前进，此数为稳定值） |
| **本分支独有的 5 个提交带 trailer 的** | **0 / 5** | 归属线索**会静默消失**，不会有任何报错 |
| 出现的 trailer 署名值 | 4 种（区分大小写） | `KujiraAgent[bot] <357582985+…>` 14、`KujiraAgent[bot] <5791552+…>` 6、`ArtomYuan <8846758+…>` 21、`kujiraagent[bot] <357582985+…>` 1 |
| **作者邮箱**（`%ae`）的大小写变体 | 2 种 | `357582985+KujiraAgent[bot]@…` 15 个提交、`357582985+kujiraagent[bot]@…` 21 个提交 |

两个真实坏法值得单独说：

- **同一个 bot 名，两个不同的数字地址。** `5791552` 是 **App ID**（见
  [证据 · GitHub App 新权限不会自动生效](../../../docs/evidence/2026-11-18-github-app-permission-propagation.md)
  的对象行），`357582985` 才是 bot 用户 ID。填错只会得到一个"看起来对"的邮箱——
  [templates/prompt-github-app-git.md.tmpl](../../../templates/prompt-github-app-git.md.tmpl) 后来专门加了一句
  "`{{BOT_USER_ID}}` 是 bot **用户**的数字 id，**不是 App ID**"，就是为这个坑。
- **大小写漂移让审计脚本漏掉一半。** 按作者邮箱 `357582985+KujiraAgent[bot]@users.noreply.github.com`
  精确匹配，只能命中 15 个提交，另外 21 个是同一个账号的小写写法（注意口径：按 **trailer 值**匹配时
  小写只有 1 条——两个字段别混）。审计归属前先跑一次区分大小写的去重。

| 坏法 | 症状 | 怎么查 |
|---|---|---|
| 把 attribution 关掉（`false` / 空串） | 新提交没有 trailer，旧提交照旧 | `git log -5 --format='%B'` 看最后几段 |
| noreply 邮箱用了 App ID | trailer 指向一个不存在的身份 | 比对 `GET /users/{app}[bot]` 返回的 `id` |
| 身份大小写漂移 | 精确匹配只覆盖部分历史 | `git log --all --format='%ae'` 后**区分大小写**去重 |
| 只信 author 字段 | bot 作者 ≠ 驱动它的人，也 ≠ 批准它的人 | 看 PR 层的声明与批准记录（[pull-requests.md](pull-requests.md)） |

## 格式合规不等于提交信息合格

本库实测：`git log --all --format='%s'` 的 59 条 subject（截至 `06fe228`），**0 条**解析不出
`type(scope)?: subject`（正则：`^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^\()]+\))?!?: .+`）。
这条现在是绿的——但**没有任何东西保证它下个 PR 还是绿的**，因为载体那一层是空的。这正是
`governance/conventional-subject` 与 `governance/commit-lint-carrier` 必须分成两条的原因。

| 真实 subject | 判定 | 为什么 |
|---|---|---|
| `fix(docs): 去掉 ADR 里写死的条数（#35 之后当天就过期） (#37)` | 好例子 | 类型、scope、subject 齐全，且 subject 说清"改了什么 + 为什么" |
| `chore(release): 1.5.0 —— 把 [Unreleased] 归入版本节 (#36)` | 好例子 | 单一目的，读者不看 diff 也知道这次动了什么 |
| `docs(guide): 元数据已改完 + 记一条 PATCH /repos 静默忽略 topics (#39)` | 合规的坏例子 | 格式可解析，但"元数据已改完"不告诉读者改了哪一项，且一条 subject 塞了两个目的 |

判据边界要划清：本规范**不评提交信息内容写得好不好**（`spec/README.md`「规范不覆盖什么」第一条），
只管格式与载体。所以上面那行"合规的坏例子"不会被任何条目判红——它靠评审治，不靠清单。

## 常见误判

| 误判 | 为什么错 | 正确做法 |
|---|---|---|
| "subject 能解析 = 提交信息合格" | 条目只判格式；内容质量是评审的事 | 格式过条目，内容看"需要 reviewer 特别看的地方" |
| "仓库里有 commitlint 配置 = 约定生效" | 配置文件存在 ≠ 它被跑过 | 确认 CI 里有 job 或 `.git/hooks/commit-msg` 真的在 |
| "本库 subject 全绿，说明这条有机制保证" | 绿的是**结果**，机制那一层是空的 | 要么加载体，要么把"不采用"写进采用记录 |
| "trailer 关掉只是少一行装饰" | 关掉后事后无法回答"哪次提交是模型写的" | 保留 trailer，要改文案就改文案，别删行 |
| "加了 commitlint 就该把它加进必需检查" | 名字进 ruleset 就多一处自锁面（ADR-0010） | 先按改名三步的顺序评估，或只用本地 hook |
| "agent 的提交格式统一，说明它遵守了我们的约定" | 它遵守的可能是工具内置的那套 | 在 `AGENTS.md` 里声明约定，或关掉内置指令（`governance/commit-convention`） |

## 条目

### 保留 agent 提交归属（未关闭 attribution，与工具无关）

`governance/commit-attribution` · L2 · should · 旧 `R029`

**为什么。** Claude Code 默认给提交加 git trailer（`Co-Authored-By: <model> <noreply@anthropic.com>`），这是 agent 参与最便宜的审计手段；把它关掉，事后就分不清哪次提交是模型写的。

**怎么做。** 删掉 attribution 的 false / 空字符串；要改文案就保留 trailer，例如 `attribution.commit: "Co-Authored-By: Claude <noreply@anthropic.com>"`。

### 仓库自己的提交约定写进 AGENTS.md

`governance/commit-convention` · L3 · may · 旧 `R041`

**为什么。** Claude Code 默认自带一套提交/PR 指令（includeGitInstructions=true）。仓库若另有约定，必须写进 AGENTS.md，否则两套指令打架；要么在这里声明，要么把内置指令关掉（includeGitInstructions=false）。

**怎么做。** 在 AGENTS.md 的“硬约定”里写一行提交约定；若关闭了内置指令，则必须写清楚完整规则。

### 提交规范有机器执行载体（可选升级）

`governance/commit-lint-carrier` · L2 · may · 旧 `R028`

**为什么。** GitHub 自家仓库大多不强制提交格式（actions/checkout 只在 CONTRIBUTING 里给一条外部链接），Claude Code 也不内置格式校验——所以这条不是行业基线，而是**可选升级**：只有当你希望按前缀自动生成 CHANGELOG / 自动发版时才需要它。

**怎么做。** 加 commitlint 配置（extends @commitlint/config-conventional），并在 CI 或 commit-msg hook 里跑起来；不需要自动化的仓库可以不管这条。

### 最近提交的 subject 符合 Conventional Commits

`governance/conventional-subject` · L3 · may · 旧 `R050`

**为什么。** 格式只在文档里 = 不生效。history 是唯一无法事后伪造的证据：subject 能解析，CHANGELOG 与 release 才能自动化。

**怎么做。** 把不合规的 subject 在后续提交里改正并说明；长期方案是让 commitlint 在 CI/hook 上拦住新提交（R028）。

## 相关

- [PR 里的 agent 参与](pull-requests.md) — 提交层之外的第二层线索：评审层声明与可单独 revert
- [归属与凭证](ownership.md) — 治理面谁能改、agent 手里那份 token 能改什么
- [AGENTS.md 该含哪几节](../writing/agents-md.md) — 提交约定的落点（`governance/commit-convention` 的"写进哪里"）
- [分支保护规则](../settings/branch-protection.md) — 必需检查名与 job 名的耦合、线性历史
- [CI 规则](../settings/ci.md) — 载体若要进 CI，先看 workflow 权限与 Action 固定 SHA
- [采用记录规则](../adoption/record.md) — 不加载体时，把"不采用 + 理由"写下来
- [guide/05 · Agent 参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md) — 留痕与回滚、反例表
- [guide/06 · 信息该放哪](../../../guide/06-信息该放哪.zh-CN.md) — subject 可解析才能自动生成 CHANGELOG
- [guide/03 · 文档该怎么写](../../../guide/03-文档该怎么写.zh-CN.md) — `AGENTS.md` 里"两套指令打架"的原处
- [ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md) — 删掉载体留下的名字如何锁死 `main`
