# PR 里的 agent 参与规则

> 板块 `governance` · 本页承载 2 条条目：`governance/pr-declaration`（L3 · may · 旧 `R048`）·
> `governance/revertable`（L3 · may · 旧 `R049`）
> 讲解与事故见 [guide/05 · Agent 参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)。

## 一句话

PR 是**评审层**，提交是**历史层**，两层各留一条线索，谁也替不了谁：trailer 让三个月后还能问"这是谁写的"，
PR 声明让 reviewer 在读 diff **之前**就知道该怎么读它。
另一条更硬：**能撤掉的改动才叫 agent 参与**——一个 PR 混三个目的，revert 就等于把好的部分一起丢掉。

## 两层线索，别指望一层包打天下

| 层 | 机制 | 谁在什么时候读到 | 本库落点 |
|---|---|---|---|
| 提交层 | `Co-authored-by` trailer（`governance/commit-attribution`，旧 `R029`） | 事后审计、`git log`、bisect | 历史里 26 / 59 个提交带 trailer（`git log --all` 实测，截至 `06fe228`；稳定口径看 `main`：21 / 44） |
| 评审层 | PR 描述第一节的工具 / 模型 + 人工复核人（`governance/pr-declaration`，旧 `R048`） | reviewer 决定"这个 diff 该怎么读"的那一刻 | [`.github/PULL_REQUEST_TEMPLATE.md`](../../../.github/PULL_REQUEST_TEMPLATE.md) 的第一节 |

两条**并列、不互相推翻**。这不是和稀泥，是有反例逼出来的：`kubernetes/kubernetes` 走的是相反路线——
"**Do not add `Co-authored-by:`** in commit messages"，把归属移到 PR 描述与 AI 使用声明里，
避免提交历史被机器署名污染
（采样记录见 [docs/evidence/2026-11-18-agent-docs-sampling.md](../../../docs/evidence/2026-11-18-agent-docs-sampling.md) §三）。
[ADR-0011](../../../docs/adr/0011-github-management-rules.md) 把这件事写得很直白：`R048` 与 `R029` 有表面张力，
本库的处理是两层线索并存，**这是妥协，不是消解**——所以 `R048` 只停在 `may`，评审时值得盯一眼。

## 声明写什么才算数

| 写法 | 算不算数 | 为什么 |
|---|---|---|
| 空着不填 | 不算 | 沉默会被读成"没有 agent 参与"，而它往往是错的 |
| "用了 AI" | 不算 | 没有工具/模型，事后无法判断该用哪种复现方式；没有复核人，责任落不到人 |
| `工具/模型 · 人工复核人：<@user>` | 算 | 两样都在：怎么来的 + 谁背书 |
| `无` | 算 | 显式的"没有"是一种结论，不是遗漏（模板注释原话：没有就写"无"） |

**复核人那一栏比工具那一栏值钱。** 官方口径是"最后一票在分支保护和批准合并的那个人"
（[guide/05 §0](../../../guide/05-Agent参与怎么管理.zh-CN.md)）：agent 可以是作者、可以是评审的第一读者，
不能是"通过"的那一方。声明复核人就是把这句话落到一份能被 grep 的文件里。

顺带一条边界：声明**不改变**评审强度。它是给 reviewer 的输入，不是免责条款——
`R048` 判的是"有没有声明"，不判"声明得诚不诚实"，后者只有 diff 本身能回答。

## 怎么算"可单独 revert"：五步可操作判据

L3 的判据是"可拒绝、可回滚、不腐烂"。"可拒绝"有闸门（`settings/main-protection` 旧 `R060`、
`settings/required-check-names` 旧 `R043`），而"可回滚"此前**没有任何条目**——这就是 `governance/revertable` 补的洞。
判据要能落到动作上，按顺序过五步：

1. **一条命令的判据**：在**被 revert 提交所在的 tree（它的合并点）**上 `git revert <squash-sha>` 不带冲突。
   只读探针：`git show <squash-sha> | git apply -R --check -`——必须在合并点上跑，后续重写会让旧补丁
   在当前 HEAD 上反向应用失败（本页四个正例在 `06fe228` 上全部失败，正是这个原因）。
   带冲突就说明这次改动和别的改动缠在一起了，先回去拆 PR，别急着找"怎么强行 revert"。
2. **前置开关**：只允许 squash + 线性历史（本库 `AGENTS.md` 的保护表就是这么写的）。
   merge commit 会把一条 PR 的变化摊到两个父提交上，`git revert -m 1` 属于考古，不属于回滚。
   开关本身见 [分支保护规则](../settings/branch-protection.md)。
3. **一个 PR 一个目的**：判据是"PR 描述能不能用一句话说完这次改动的目的"。
   说不完（出现"顺便""另外还"），就是三个 PR。顺序与理由见 [spec/agent-playbook.md](../../agent-playbook.md) §3。
4. **列出 diff 撤不掉的东西**：git 只管 diff。本库 1.5.0 就有两类"不在 diff 里"的改动——
   仓库元数据（描述 / topics，走 `PATCH /repos` 与 `PUT /repos/{owner}/{repo}/topics`）和版本锚点
   （tag `v1.4.0`、Release 页、给 `v1` 标 *Superseded*，走 API 建）。
   revert 那个 PR，tag 还在、Release 还在、topics 还在。所以 PR 描述里必须有一节写清
   **"怎么回滚"：逐条列出 git 撤不掉的副作用 + 对应的撤销动作**。缺这一节，这个 PR 的回滚成本是未知的。
5. **查下游有没有消费掉它**：已发布的 tag、已发出去的采用记录、别人钉住的规则 ID。
   移动 tag 是对所有钉住它的人毁约，且损坏隐形——优先发**更正版本**，别 revert 已发布的历史
   （见 [发布物规则](../release/artifact.md)）。查法：`git log --oneline -S '<规则 ID 或路径>'` 看谁引用了它。

| 情况 | 算不算可单独 revert | 怎么办 |
|---|---|---|
| 一个 PR 只改文档，diff 干净 | 算 | 直接 `git revert` |
| 一个 PR 很大，但只有一个目的（如 1.4.0 删检查器） | **算**——大 ≠ 不可回滚 | revert 即整树恢复；代价是同时撤掉它的 ADR 决定，要补说明 |
| 一个 PR 改了文件，又顺手改了 ruleset / tag / topics | 不算 | 回滚要两步：revert + 手动改回平台设置。PR 描述里必须写出第二步 |
| 一个 PR 混了"加条目"和"推翻旧决定" | 不算 | 拆成两个 PR；否则 revert 会把两个决定一起撤掉 |
| 改动已被下游 tag / 采用记录引用 | 不算（历史层） | 发更正版本，别动已发布历史 |

## 本库历史里的正例与反例

| PR | 内容 | 判定 |
|---|---|---|
| #37 / #38 / #39 | 各修一处：去掉 ADR 里写死的条数 / 把"改不了描述"的成因写对 / 记一条 `PATCH /repos` 静默忽略 `topics` | **正例**——但依赖关系要写清：#37 与另两个独立；#38→#39 是 create→modify 依赖（4/4 文件重合，#39 改的正是 #38 新建的证据文件），revert #38 会删掉 #39 已改过的文件——这恰好就是第 4 步要你提前列出来的那种副作用 |
| #22 | 删掉 `checker/`、`tests/`、`action.yml`、`.github/workflows/ci.yml`（ADR-0009） | **正例**。体量大但目的单一，revert 就是整树恢复；它的问题不是不可回滚，是回滚之后 ruleset 里的旧检查名没人上报——见 [ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md) |
| #35 | 一次做了：新增 11 条管理面条目、**改写编号策略**（推翻 #33 立的"号段 = 档位"）、把符合性声明同步到 1.5.0、给 PR 模板加"本次是否有 agent 参与"一节、同步 `guide/00`/`05`/`07` 的中英附录 | **反例**。CHANGELOG 自己写着"本 PR 就是推翻它的那一个"——revert 它等于同时撤掉"加条目"和"推翻号段约定"两个决定，而这两个决定本该分开评审、分开回滚 |

`#35` 值得留着当反例，是因为它**不是失控**：那批改动确实互相牵连，作者也解释了为什么放一起。
它只是把回滚粒度换成了评审粒度——而 `governance/revertable` 要的就是这笔账被算清楚，最好写在 PR 描述里。

## 常见误判

| 误判 | 为什么错 | 正确做法 |
|---|---|---|
| "revert 过一次，说明这仓库可回滚" | 一次成功不代表**下一个** PR 可回滚；粒度是 PR 的属性，不是仓库的 | 每个 PR 自己过一遍上面五步 |
| "PR 小就一定可 revert" | 小 PR 也能改 ruleset / tag / topics，git 撤不掉 | 副作用清单写进 PR 描述 |
| "有线性历史就自动可回滚" | 线性历史只保证一条 PR 对应一条提交，不保证那条提交只有一个目的 | 一个 PR 一个目的才是根 |
| "PR 里声明 agent 参与是形式主义" | 它是 reviewer 决定"这个 diff 该怎么读"的第一行输入 | 按"工具/模型 + 人工复核人"填 |
| "声明了 agent 参与，评审就可以松一点" | 最后一票在批准合并的人，声明只交代来源，不转移责任 | 复核人那一栏填真人 |
| "`R048` 以后可以取代 `R029`" | 两层线索的读者不同、寿命不同；PR 讨论会沉，trailer 跟着历史走 | 两层都留；要学 k8s 那套就在采用记录里写明理由 |

## 条目

### PR 层面声明 agent 参与（工具 / 是否人工复核）

`governance/pr-declaration` · L3 · may · 旧 `R048`

**为什么。** `R029` 的 trailer 是**提交层**线索，PR 描述里的声明是**评审层**线索——reviewer 在决定"这个 diff 该怎么读"之前就该看到它。`kubernetes/kubernetes` 走的是相反路线：禁止 `Co-authored-by`，改为在 PR 里声明 AI 使用并要求人类作者负全责。**两种文化都成立**，所以这条只到 `may`，且不推翻 `R029`。

**怎么做。** PR 模板加一行：`本次是否有 agent 参与：<工具/模型> · 人工复核人：<@user>`。与 `R029` 组合：提交层与评审层各留一条线索。分歧记录见 [2026-11-18 采样 §三](../../../docs/evidence/2026-11-18-agent-docs-sampling.md)。

### agent 的改动可单独 revert

`governance/revertable` · L3 · may · 旧 `R049`

**为什么。** L3 的判据是"可拒绝、可回滚、不腐烂"，但"可拒绝"有闸门（`R060`、`R043`），**"可回滚"此前没有任何条目**。一个 PR 混多个目的时，revert 等于把好的部分一起丢掉。

**怎么做。** 一个 PR 只做一件事（[spec/agent-playbook.md](../../agent-playbook.md) §3）；只允许 squash + 线性历史（`R051`）；PR 描述里写清"怎么回滚"。

## 相关

- [提交规则](commits.md) — 提交层的归属线索（`governance/commit-attribution`，旧 `R029`）
- [归属与凭证](ownership.md) — 谁批准、谁拥有治理面、agent 手里的 token 能改什么
- [协作文件规则](../documents/collaboration.md) — PR 模板的存在性与自检清单
- [PR 模板写法](../writing/pr-template.md) — 模板该有哪几节、"怎么验证的"为什么必须贴输出
- [分支保护规则](../settings/branch-protection.md) — 线性历史、squash、必需检查名（"可拒绝"那一半）
- [发布物规则](../release/artifact.md) — tag / Release 是 diff 撤不掉的副作用，优先发更正版本
- [采用记录规则](../adoption/record.md) — "谁能改 ruleset"必须落在采用记录里，否则自锁没人能解
- [guide/05 · Agent 参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md) — 三道闸、隔离与回滚、反例表
- [ADR-0011](../../../docs/adr/0011-github-management-rules.md) — `R048` 与 `R029` 的张力为什么按"并存"处理
- [ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md) — 一次"回滚之后才发现门禁也被删了"的真实自锁
