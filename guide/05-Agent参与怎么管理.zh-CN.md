# 05 · Agent 参与怎么管理
**[English](05-Agent参与怎么管理.md)** · 简体中文

> 这一章讲**当 agent 的提交开始变多时，怎么管**。
> 依据：Anthropic 的 [Best practices](https://code.claude.com/docs/en/best-practices)、
> [Permissions](https://code.claude.com/docs/en/permissions)、[Hooks](https://code.claude.com/docs/en/hooks)、
> [Worktrees](https://code.claude.com/docs/en/worktrees)；GitHub 的分支保护与 CODEOWNERS 规则；
> 以及 `cli/cli`、`python/cpython`、`microsoft/vscode` 仓库里**真实写着的** agent 门槛。

---

## 0. 管理只需要回答四个问题

| 问题 | 机制 | 谁执行 |
|---|---|---|
| **谁能改** | 分支保护、CODEOWNERS、deny 规则、managed settings | 平台 / harness |
| **什么时候允许动手** | 贡献资格门槛、开工前检查 | 人定的规则 + agent 遵守 |
| **怎么判合格** | required checks、PR 模板、人的最后一票 | CI + 人 |
| **怎么留痕与回滚** | 归属 trailer、CHANGELOG、ADR、PR 讨论、worktree | 工具 + 惯例 |

一句话立场（官方原话）：

> Who has the last word: **Branch protection, a person who approves the merge.**
> （最后一票在分支保护和批准合并的那个人。）

**agent 永远不是最终裁决者。** 它可以是作者、可以是评审的第一读者，不能是"通过"的那一方。

---

## 1. 谁能改：先把门装上

### 1.1 分支保护是唯一真正硬的边界

| 设置 | 值 | 作用 |
|---|---|---|
| Require a pull request | ✅ | 禁止直推 |
| Required approvals | ≥1 | 人必须看 |
| Dismiss stale approvals | ✅ | 新提交作废旧批准 |
| **Require review from Code Owners** | ✅ | 让 `CODEOWNERS` 真正生效（不开就是装饰） |
| Require status checks | `lint`、`test` 等 | CI 门禁 |
| Allow force pushes / deletions | ❌ | 保护历史 |
| **Do not allow bypassing** | ✅ | 开了之后管理员也必须走门禁；紧急通道改用 Rulesets 的 **bypass list** 精确授权，而不是靠"管理员都能绕过" |

**关于 bypass，两条必须说清的补充**

- 这一项决定了上面整张表在"赶时间"时还算不算数。绕过的动机通常不是恶意，而是"我急着发"——而 agent 让改动变便宜之后，这个动机出现得更频繁。
- 例外可以存在，但要**被授权并被记录**：开 `Do not allow bypassing`，在 Rulesets 的 bypass list 里点名"谁可以在什么条件下绕过"，并把"为什么允许"写进 ADR。**"视团队"不是一种设置，是一种遗忘。**
- 本仓库**已开启** admin 强制（`enforce_admins = true`，见 [ADR-0004](../docs/adr/0004-all-changes-via-pr.md) 与 [分支保护实测](../docs/evidence/2026-11-17-protection-probe.md)）；破窗流程要写成"谁能改 ruleset + 最短恢复路径"，见 [ADR-0010](../docs/adr/0010-required-checks-self-lock.md)——**规范允许例外，但要求例外被写下来。**

### 1.2 治理面单独设 owner

```
/.claude/               @org/agent-ops
/.github/workflows/     @org/agent-ops
/AGENTS.md              @org/agent-ops
```

理由：**agent 改代码是工作，agent 改自己的权限与门禁是越权。**
这三处必须走人工 PR，且最好由不同的人看。

### 1.3 组织级用托管配置

个人 `settings.json` 可以改，但**managed settings（组织下发）不能被个人覆盖**。
需要"全公司都必须遵守"的几条，放这一层；放在仓库里的规则，永远只是"这个仓库的约定"。

---

## 2. 什么时候允许动手：真实仓库的门槛

这是最容易被忽略、但头部仓库都在做的一件事——**在 agent 开始写代码之前设卡**。

### `cli/cli` 的做法

> 摘录（2026-11-17 抓取，`cli/cli` 仓库 `AGENTS.md`）：
>
> "**Do not prepare an unsolicited external upstream pull request to cli/cli.**"
> "Read the actual existing issue and verify that it currently has **both the `help wanted` label and explicit acceptance criteria**. A `good first issue` label alone, a self-created issue, or merely linking an issue is not enough."
> "**Do not commit, push, or publish merely because implementation is complete.**"

中文要点：

- **不许为未经邀请的上游 PR 做准备**：必须同时有 `help wanted` 标签 **和**明确的验收标准；
  只凭 `good first issue`、自己开的 issue、或"链接了一个 issue"都不算；
- 标了 `core` 的 issue 不动；
- 拿不到资格、或资格不明确时，**停止实现**，向人解释政策，不要自动创建 issue/讨论/评论；
- 授权是具体的：**对该仓库有 `write` 权限的已认证身份**才构成"被要求做这件事"的授权；fork 所有权、一句"修一下吧"、或看起来有益，都不构成；
- **"实现完了"不等于可以 commit、push、publish。**

### `python/cpython` 的做法

> 摘录（2026-11-17 抓取，`python/cpython` 仓库 `AGENTS.md`）：
>
> "CPython has a [policy on the use of AI tools](https://devguide.python.org/getting-started/ai-tools/). All use of AI tools and agents when working on or interacting with CPython must follow it."
> "**Primary directive**: Read the policy before making or proposing any changes."
> "Do not auto-generate issues with AI tools."

中文要点：

- 开头就是"先读 AI 政策"，不读不许提改动；
- 不许用 AI 自动开 issue；
- 附了去重命令（`gh search issues …`），把"别开重复 issue"变成可执行的动作。

### 可以照搬的四条

1. **开工前有资格判断**（有没有被邀请、有没有验收标准）；
2. **有"停止条件"**（资格不明 → 停，不许自己扩大范围）；
3. **把"别做某事"变成可执行的命令**（去重搜索）；
4. **明写"完成 ≠ 可以提交"**，把提交/推送/发布当成需要单独决定的事。

---

## 3. 怎么判合格：三道闸

| 闸 | 谁执行 | 判什么 |
|---|---|---|
| 机器闸 | CI required checks | 能不能编译、测试过不过、lint 干净 |
| 结构闸 | PR 模板 | 有没有说"改了什么/为什么/怎么验证的" |
| 人闸 | 评审者 | 意图对不对、边界条件、影响面、能不能回滚 |

**PR 模板里最值钱的两栏**：

- **怎么验证的**——要求贴真实输出，不接受"已测试"；
- **需要 reviewer 特别看的地方**——把评审从"通读 diff"变成"重点核对三处"。

---

## 4. 怎么留痕：归属、变更、决策

| 留痕对象 | 机制 | 说明 |
|---|---|---|
| 这次提交是谁写的 | **git trailer**（Claude Code 默认写 `Co-Authored-By: <model> <noreply@anthropic.com>`） | 配置项是 `attribution.commit`；不要自造 `Agent:` 之类的新行 |
| 这个版本改了什么 | `CHANGELOG.md` | 只写用户可感知的变化，带 PR 号 |
| 为什么这么设计 | `docs/adr/` | 选项里必须写"为什么不选" |
| 当时讨论了什么 | PR 描述与评论 | 模板强制了结构，讨论才不会散 |

**归属为什么重要**：它是事后唯一能回答"这段代码是谁写的、能不能复现"的线索。
把它关掉（`attribution: false` 或空串）等于主动放弃审计能力——这也是本库把它列为 `should` 的唯一一条提交相关规则。

---

## 5. 怎么隔离与回滚

| 手段 | 用途 | 注意 |
|---|---|---|
| **worktree** | 多个并行任务互不踩文件 | 各自独立分支；哪些 gitignore 文件要带进去用 `.worktreeinclude` 声明 |
| **小步提交** | 一次改动只有一个目的 | 混入无关重构的 PR 无法评审，也无法干净 revert |
| **禁止 force push** | 历史不被重写 | 这是回滚的前提 |
| **`revert` 优先于"再改回去"** | 出问题时先恢复可用状态 | 修 bug 是第二件事 |

**回滚的判据**：这次改动能不能用一条 `git revert` 干净撤掉？
如果有数据迁移、外部副作用、或已发布的接口变更——那就不是"回滚"，是"发布事故"，需要单独的 runbook。

---

## 6. 别让 agent 管治理面

`cli/cli` 的 agent 定义里有一种值得抄的结构：

```markdown
## Repository Instructions Overlay
If `.github/aw/instructions.md` exists, load it with:
@.github/aw/instructions.md
Precedence: repository overlay instructions override defaults in this agent when they conflict.
```

两个要点：

1. **agent 的默认行为与仓库的覆盖层分开存放**，冲突时明写谁优先——避免"两套规则打架、模型随机选"；
2. **覆盖层本身在 `.github/` 里，受 CODEOWNERS 管辖**——agent 改不了自己的规则。

同理：`microsoft/vscode` 把 `agents/`、`skills/`、`instructions/`、`hooks/` 都放在 `.github/` 下，
和 workflows 一起接受同一套评审与权限。**把 agent 的"能力"和"约束"放在同一个受管目录里**，比分散在两处更难被绕过。

---

## 7. 组织级与规模化

| 场景 | 做法 |
|---|---|
| 多个仓库要同一套底线 | 组织级 `.github` 仓库放默认 `CONTRIBUTING`/`SECURITY`/模板，单仓库可覆盖 |
| 必须无条件遵守的规则 | managed settings（个人与仓库都无法覆盖） |
| 并行跑多个任务 | worktree + 各自的 subagent；不要在一个会话里串行做五件事 |
| 无人值守的长任务 | 明确检查 + 目标条件 + 预算上限（`--max-turns` / `--max-budget-usd`） |

---

## 8. 反例

| 反例 | 后果 | 改法 |
|---|---|---|
| agent 直推 main | 没有评审、没有回滚点 | 分支保护 |
| 开了 CODEOWNERS 但没开 `Require review from Code Owners` | 看起来有治理，实际零效果 | 打开那个开关 |
| agent 能改 `.github/workflows/` 和 `.claude/` | 自己给自己放行 | 治理面单独 owner + deny |
| 关掉 attribution | 事后分不清哪次提交是模型写的 | 保留 trailer |
| 用 PR 描述里一句"已测试"当验证 | 假绿 | 要求贴输出 |
| 一个 PR 混三轮重构 | 无法评审、无法回滚 | 强制聚焦，拆 PR |
| 用 prompt hook 做安全拦截 | 仍是模型判断 | `command` hook + `exit 2` + `onFailure: block` |

---

## 9. 判据：治理是否真的在起作用

**硬性（这四条不成立，治理等于没装）**

- [ ] 分支保护开了吗？`Require review from Code Owners` 开了吗？
- [ ] `/.claude/`、`/.github/workflows/`、`/AGENTS.md` 有独立 owner 吗？
- [ ] 出问题时能用一条 `git revert` 撤掉吗？
- [ ] 有没有哪条"绝不能例外"的规则还只写在文档里？

**视情况（没做也可以，但要能说出理由）**

- [ ] agent 有没有"开工前资格判断"和"停止条件"？
- [ ] PR 模板是否强制"怎么验证的"与"需要特别看的地方"？
- [ ] 提交里能看出是哪个模型写的吗（`Co-Authored-By` trailer）？

> 这些不是评分项。勾满不等于治理到位，勾不满也不等于有问题——**能说出"为什么不"比勾满更重要。**

---

## 10. 依据

| 论断 | 来源 |
|---|---|
| "最后一票在分支保护和批准合并的人" | [Best practices](https://code.claude.com/docs/en/best-practices) |
| deny 规则、sandbox、managed settings 的强制力 | [Permissions](https://code.claude.com/docs/en/permissions) · [Settings](https://code.claude.com/docs/en/settings) |
| hook 的确定性、`exit 2`、`onFailure: block` | [Hooks reference](https://code.claude.com/docs/en/hooks) |
| worktree 隔离与 `.worktreeinclude` | [Worktrees](https://code.claude.com/docs/en/worktrees) |
| 默认 `Co-Authored-By` trailer、`attribution` 配置 | [Settings reference · Git and attribution](https://code.claude.com/docs/en/settings-reference) |
| 开工前资格门槛、"实现完 ≠ 可提交" | `cli/cli` 的 `AGENTS.md`（实测） |
| 先读 AI 政策、不许自动开 issue、去重命令 | `python/cpython` 的 `AGENTS.md`（实测） |
| 覆盖层 + 优先级声明；agent 能力与约束同目录受管 | `cli/cli` 的 `.github/agents/agentic-workflows.md`、`microsoft/vscode` 的 `.github/`（实测） |
| 分支保护、CODEOWNERS 开关 | [About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) |
---

## 附：一种你一定会遇到的自锁 —— 必需检查指向了已删除的 job

**现象**：PR 上四个检查永远显示 `Expected — Waiting for status to be reported`，永远不失败也不通过，
合并按钮一直是灰的。你会怀疑是不是"运行额度用完了"——不是。

**原因**：`required status checks` 里存的是**名字**，不是 job 本身。它要求"必须有某个东西上报这个名字"。
一旦你删掉 workflow、或改了 job 名，旧名字就再没有生产者，于是**永久 pending**——
GitHub 不会超时放行，也不会拿历史提交上跑过的结果顶替（只看这次 PR 的 head commit）。

**为什么危险**：改名/删 CI 通常被当成"清理"，看起来无害。但它是**自锁**：
main 从此不可合并，而没有任何工具会提醒你"你刚把生产者删了"。

**判断方法**（30 秒）：

```
required_status_checks 里的 context 列表  ⇄  当前 workflow 里实际存在的 job 名
两者必须一一对应。多一个 → 永久 pending
```

**预防**

1. **重命名 job 走三步**：先加新名 job（旧名保留）→ 改 ruleset 指向新名 → 下一个 PR 删旧 job。
   **不要在一个 PR 里同时改名和改规则。**
2. 动 `workflows/` 之前，把"哪些 context 被 ruleset 依赖"写进 `AGENTS.md`——否则下一个人（或 agent）不知道自己在拆什么。
3. 记住改 ruleset 需要 `administration` 权限：**用 App token 干活的人通常没有**，而且缺的原因多半不是你猜的那个——
   在 App 设置里勾上权限**并不会让它生效**，installation 必须先批准这次扩权；批准之前，
   `token.permissions` 里连这个 key 都不存在。实测见
   [docs/evidence/2026-11-18-github-app-permission-propagation.md](../docs/evidence/2026-11-18-github-app-permission-propagation.md)。
   所以：**查 `token.permissions`，别看 App 设置页的勾选**；并且采用记录里必须写清"谁能改 ruleset"，
   否则自锁之后没人能解。
   同一类陷阱也埋伏在你用来善后的 API 上：`PATCH /repos` 会**静默忽略** `topics` 字段（返回 200、什么都没改），
   topics 要走 `PUT /repos/{owner}/{repo}/topics`。**改完回读**——2xx 只代表请求合法，不代表你传的字段都被接受了。

**破窗**（`must` 级，任何采用本规范的仓库都该写下来）：

- 谁有权改 ruleset / 分支保护（人名或团队，不是"管理员"这种模糊说法）；
- 自锁时的最短恢复路径：要么改必需检查清单，要么临时关掉 `Require status checks` 这条规则；
- 恢复后**补一条 ADR**，写明为什么自锁、谁解开的——否则下次还会踩。

---

## 附：本章对应的自查项

只做导航——判据本身在 [spec/rules/README.md](../spec/rules/README.md)。

| 条目 | 本章解释它什么 |
|---|---|
| `R011` | 治理面单独设 owner——agent 改动的第一道人工闸门 |
| `R029` | 保留 agent 归属，让"哪次提交是模型写的"始终可回答 |
| `R041` | agent 工具自带一套提交指令时，以谁的为准 |
| `R044` | 治理文件为什么要单独的 owner，以及为什么 agent 不能自己改 |
| `R048` | 在 PR 层面声明 agent 参与，与提交层的 trailer 并列 |
| `R049` | 让 agent 的改动能被单独 revert |
| `R050` | 提交历史是唯一无法事后伪造的证据 |
| `R060` | 门禁本身：必须 PR、必需检查、禁止 admin 绕过 |
| `R062` | agent 手里那份凭证的爆炸半径 |

> **这里曾经是覆盖缺口，`1.5.0` 补上了。** 本章论证的那几道门一直是**结构性**事实、可判定，本该进 checklist，
> 但当时没有条目。现在有了：`R060`（保护）、`R043`（必需检查名，见 [guide/07](07-该开哪些设置.zh-CN.md)）、
> `R044`（code owners）、`R049`（回滚路径）。它们为什么只停在 `should`、代价是什么，记在
> [ADR-0011](../docs/adr/0011-github-management-rules.md)。

证据：[docs/evidence/2026-11-17-protection-probe.md](../docs/evidence/2026-11-17-protection-probe.md)。
