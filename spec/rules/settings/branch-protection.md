# 分支保护规则

> 板块 `settings` · 本页承载 3 条条目：`settings/main-protection`（L2 · should · 旧 `R060`）·
> `settings/required-check-names`（L3 · should · 旧 `R043`）· `settings/linear-history`（L3 · may · 旧 `R051`）
> 讲解与实测值见 [guide/07 §1–3、§6](../../../guide/07-该开哪些设置.zh-CN.md)。

## 一句话

**`AGENTS.md` 里写的"禁区"是提示，分支保护才是闸门。** 提示可以被忽略，闸门不能。

## 一条原则

**设置是"不依赖记忆的约束"。** 只要某件事必须永远成立，就用平台机制表达，而不是写进文档里的一个句子。

推论同样重要：**每个你打开的开关都必须有主人。** 没人负责的设置页，在它把仓库锁死的那天也没人会去修。
这条推论不是修辞——本库真的被自己配的开关锁过一次，见下面「唯一会把你锁在外面的一项」。

## 为什么 agent 参与的仓库更需要这道门

agent 能提 PR、能改 `.github/workflows/`、能让检查变绿。如果它改得了 CI，它就等于能给自己放行——
此时所有写在文档里的"agent 不得做 X"都退化成建议。

所以顺序是：**先有闸门，再谈信任**。判据不是"这个 agent 可不可信"，而是"它失信的时候你拦不拦得住"。

## 该开哪几项

用 **ruleset**，不要用旧版分支保护（旧版没有 `bypass_actors` 的细粒度控制，也没有统一的策略来源）。

| 规则 | 作用 | 不开会怎样 |
|---|---|---|
| `deletion` | 禁止删除 `main` | 一次误操作就没有主干了 |
| `non_fast_forward` | 禁止 force push | 历史可被静默重写，已审过的提交消失 |
| `pull_request` | 必须走 PR；≥1 人工批准；只允许 squash | 直推绕过评审，批准记录不存在 |
| `required_status_checks` | 指定检查必须绿 | 见下面那一节——**这一项配错会锁死仓库** |
| `required_linear_history` | 只允许线性历史 | merge commit 让 revert 变成考古 |
| `bypass_actors` **留空** | admin 也不能绕过 | "管理员可绕过"一开，上面五条全部变成建议 |

**`bypass_actors` 留空是这张表里唯一容易被"方便一下"就关掉的一项。** 需要应急通道，就显式写进
ruleset 的 bypass 名单并留下记录，而不是打开"管理员可绕过"这个总开关。

为什么"谁能绕过"必须显式回答：**写代码的人和能改门禁的人，通常不是同一个人。**
能 push 的 token 一般改不了 ruleset——本仓库就是这么被锁住的。

## 唯一会把你锁在外面的一项

`required_status_checks` 存的是**名字字符串**，不是引用。每个名字都必须有东西去上报；
删掉 workflow 或改掉 job 名，那个名字就永久停在
`Expected — Waiting for status to be reported`——**不超时，也不认历史提交**，`main` 从此不可合并。

本库真实发生过一次，恢复要靠改 ruleset。复盘见
[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md)。

三条规矩：

1. 检查名一律**从下拉里选**，不要手打。非 ASCII 名字里错一个字，界面上完全看不出来，效果上是致命的。
2. 改 job 名的顺序固定：**先加新名字的 job → 改 ruleset → 下一个 PR 再删旧 job**。
   反过来做，中间那个 PR 就是不可合并的。
3. 把当前保护配置写进 `AGENTS.md`，让所有人在动 CI 之前先看见这张表。

## 线性历史为什么值得要

merge commit 会把一条 PR 的变化混进两条父提交，出问题时难以定位与回滚。
线性历史让 revert、cherry-pick、审计都变成"看一条提交"。

已存在的 merge **不必重写**——这条规则管的是从现在起的方向，不是考古。

## 条目

### `main` 受保护：必须 PR + 必需检查 + 禁止删除与强推，且对 admin 也生效

`settings/main-protection` · L2 · should · 旧 `R060`

**为什么。** 这是唯一真正**硬**的边界：`AGENTS.md` 里写的"禁区"是提示，分支保护才是闸门。
agent 若能改 CI，就等于能给自己放行。反面教材本库亲身踩过——必需检查名写错导致 `main`
永久不可合并（[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md)），
说明这道门配错的代价是双向的。

**怎么做。** 用 ruleset（不要用旧版分支保护）：`deletion` + `non_fast_forward` +
`pull_request`（≥1 人工批准、只允许 squash）+ `required_status_checks` +
`required_linear_history`；`bypass_actors` 留空，让 admin 也不能绕过。
当前实测值见 [guide/07](../../../guide/07-该开哪些设置.zh-CN.md)。

### 必需检查的名字与 workflow 的 job 名逐字一致

`settings/required-check-names` · L3 · should · 旧 `R043`

**为什么。** ruleset 里存的是**字符串**，不是引用。job 改名或删掉，那一项就永远停在
`Expected — Waiting for status to be reported`，`main` 从此不可合并——**本仓库真的发生过一次**，
恢复要靠改 ruleset。

**怎么做。** 顺序固定：先加新名字的 job → 改 ruleset → **下一个 PR** 再删旧 job。
把当前保护配置写进 `AGENTS.md`，让所有人在动 CI 之前先看见这张表。
事故复盘：[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md)。

### 最近提交是线性历史（无 merge commit）

`settings/linear-history` · L3 · may · 旧 `R051`

**为什么。** 线性历史让 revert、cherry-pick、审计都变简单；merge commit 会把一条 PR 的变化
混进两条父提交，出问题时难以定位与回滚。

**怎么做。** 仓库设置启用 Squash merge 或 Rebase merge，关闭 Merge commit；已存在的 merge 不必重写。

## 相关

- [CI 规则](ci.md) — 必需检查由 workflow 上报，两边是一体两面
- [采用记录规则](../adoption/record.md) — 保护配置、谁能改、破窗流程都要落进采用记录
- [guide/07 §1–3、§6、§7](../../../guide/07-该开哪些设置.zh-CN.md) — 开关清单与实测值
- [guide/05 附录](../../../guide/05-Agent参与怎么管理.zh-CN.md) — 完整事故过程
