# 归属与凭证规则

> 板块 `governance` · 本页承载 2 条条目：`governance/owner`（L3 · should · 旧 `R044`）·
> `governance/credentials`（L2 · should · 旧 `R062`）
> 讲解与事故见 [guide/05 · Agent 参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)。

## 一句话

`AGENTS.md`、`.github/workflows/`、`CODEOWNERS` 是**规则本身**：谁能改它们，谁就能改自己的权限边界。
所以这一页只判两件事——**改这些文件要不要经过一个不写代码的人**，以及**agent 手里那份凭证能做到什么**。
本库在第一件事上**不合格**，而且不合格的方式很典型：文件写了、开关没开、owner 只有一个人。

## 治理面是"规则本身"

| 路径 | 为什么算治理面 | 被改了会怎样 |
|---|---|---|
| `/AGENTS.md` | agent 处理这个仓库的唯一事实源，"禁区"全在里面 | 禁区可以被一次提交抹掉 |
| `/.github/workflows/` | 必需检查的生产者 | 改 job 名 = 拆门禁（见 [ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md)）；加 job = 给自己放行 |
| `/.github/` 其余部分 | PR 模板、Issue 模板、`CODEOWNERS` 本身 | 评审结构被削弱，且改 `CODEOWNERS` 就是改"谁必须批" |
| 工具目录（若存在，如 `/.claude/`） | 权限基线、hooks、skills | deny 规则一删，本地那层拦截当场消失 |

判断标准不是"这个文件重不重要"，而是**"改它能不能扩大改动者的权限"**。
`spec/` 里的判据很重要，但改它不会让谁获得新权限；`/.github/workflows/` 一行都不重要，改对一行就能让门禁消失。

真实仓库都按这条划线：`microsoft/vscode` 把 `agents/`、`skills/`、`instructions/`、`hooks/` 全放在 `.github/` 下，
和 workflows 一起接受同一套评审与权限；`cli/cli` 的仓库覆盖层在 `.github/aw/instructions.md`，
同样受 `CODEOWNERS` 管辖——**agent 的"能力"和"约束"放在同一个受管目录里，比分散两处更难被绕过**
（原处见 [guide/05 §6](../../../guide/05-Agent参与怎么管理.zh-CN.md)）。

## 三道门，缺一道就只是装饰

| 门 | 机制 | 它实际拦什么 | 缺了会怎样 |
|---|---|---|---|
| 1. 指派 | `CODEOWNERS` 按路径写 owner | 自动把评审人挂到 PR 上 | 没人被要求看这个 diff |
| 2. 执行 | ruleset 的 `Require review from Code Owners` | 让第 1 道门真的阻断合并 | **`CODEOWNERS` 只是一份索引，不指派任何人** |
| 3. 本地拦截 | 权限基线里 deny 掉这些路径的 `Edit`（[agent-config/permissions-deny](../agent-config/permissions.md)） | agent 在动手之前就被挡住 | 只能靠事后评审发现 |

三道门是**串联**的，不是并列的：第 1 道没有第 2 道就是纸，第 2 道没有第 3 道就只在合并那一刻生效，
而 agent 的改动在合并前已经在本地落盘了。第 2 道门的官方口径也写得很直白——
"有 `CODEOWNERS` 才开；不开的话那个文件就是装饰"（[guide/07 §2](../../../guide/07-该开哪些设置.zh-CN.md)）。

## 本库现状：`governance/owner` 这条不合格

不自曝的规范库没有信誉。`release/self-noncompliance`（旧 `R069`）要求规范类项目在发布物的已知问题里
列出自己不合格的条目。本库对 `R044` 的自曝实际落在 [guide/00 §6](../../../guide/00-接入决策.zh-CN.md)
与 CHANGELOG 1.5.0 节（"CODEOWNERS 目前不生效"）——`R069` 本身是 1.6.0 批次才加的 `may`，
1.5.0 发布时还不存在，所以当时没有走 Release「已知问题」这个落点。这里写清楚它到底差在哪、怎么恢复。

| 判据要素 | 本库实测状态 | 证据 |
|---|---|---|
| 治理面有单独的行 | **做到了**：`CODEOWNERS` 里 `/AGENTS.md`、`/.github/` 各占一行（另有 `*`、`/spec/`、`/guide/`） | 仓库根 `.github/CODEOWNERS` |
| 这些行指向**独立**的 owner | **没做到**：五行全部指向同一个 `@ArtomYuan`。写代码的人、拥有治理面的人、批准合并的人是同一个人 | 同上 |
| `Require review from Code Owners` | **没开**：2026-11-17 的 PUT body 里 `require_code_owner_reviews = $false` | [docs/evidence/2026-11-17-protection-probe.md](../../../docs/evidence/2026-11-17-protection-probe.md) §1 |
| 文件是否生效 | **不生效**：`guide/00` 与本库 `CHANGELOG.md` 都明写"CODEOWNERS 目前只是索引 / 目前不生效" | [guide/00 §6 这个库自己怎么做的](../../../guide/00-接入决策.zh-CN.md) |
| 本地 deny 基线 | **不适用**：本库按 ADR-0009 删掉了 `.claude/`，也没有权限基线文件；这一层等于空 | ADR-0009 |

还有一处**文档与平台是两份数据**的实证：`AGENTS.md` 的保护表写"必须 PR；1 个人工批准"，
而 2026-11-17 的实测回读是 `required_approving_review_count = 0`（允许自己合并，但必须走 PR）。
两边谁对不重要——重要的是**这条判据要求你回读 ruleset，而不是读文档**。

**恢复路径（按顺序，每步都可执行）**：

1. 回读 ruleset，把 `require_code_owner_reviews` 的实际值抄下来——不要引用任何文档里的数字。
2. 确认谁有权改 ruleset（需要 `administration`）。**用 App token 干活的 agent 通常没有**，
   而且缺的原因多半不是"没申请"——见下一节。这一步没有答案，后面全部卡住。
3. 打开 `Require review from Code Owners`。第 1 道门立刻从"索引"变成"闸门"。
4. 给 `/.github/workflows/` 与 `/AGENTS.md` 指定与业务代码**不同**的 owner（组织里可以是团队，
   单人仓库可以是"第二个人"或一个只读成员）。
5. 单人仓库做不到第 4 步——那就按 [符合性声明](../../README.md) 的条件 2，把它写成**偏离 + 书面理由**，
   落进采用记录（[adoption/record](../adoption/record.md)），并同时写上"谁能改 ruleset + 破窗最短路径"
   （[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md) 结论 4）。**"做不到"和"已满足"是两句话，别混。**

## 凭证：爆炸半径由 `token.permissions` 决定，不由设置页决定

`governance/credentials` 的判据是"最小权限 + 不落盘"。本库有一次完整实测，把"最小权限"这件事
里最容易误解的部分钉死了（全文见
[docs/evidence/2026-11-18-github-app-permission-propagation.md](../../../docs/evidence/2026-11-18-github-app-permission-propagation.md)）：

| 回读点 | 实测结果 |
|---|---|
| `GET /app`（App **申请**的权限） | 16 项，含 `administration=write`、`workflows=write`、`repository_creation=write` |
| `GET /app/installations/{id}`（installation **批准**的权限） | 15 项（申请的 16 项减去 `administration`），**`administration` 这个 key 根本不存在**——不是 `read`，不是 `none`，是没有这一项 |
| `POST …/access_tokens` 返回的 `token.permissions` | 与 installation 完全一致，同样没有 `administration` |
| 实际调用 `PATCH /repos` | `403 Resource not accessible by integration`；`GET /repos` 回读 `permissions.admin = false` |
| 批准扩权后重签 token | `installation.permissions` 与 `token.permissions` 两处**都**出现 `administration = write`，调用随即成功 |

四条规律：

1. **判断 token 有没有某项权限，只看 `token.permissions` 里有没有那个 key。** App 设置页显示的是"申请"，不是"生效"。
2. **最小权限的执法点在 installation 批准那一步**，不在 App 申请那一步。本库这个 App 的申请面里带着
   `workflows=write`——也就是说 token **能**改治理面文件；把它拦下来的是批准集，不是设计意图。
   这就是本页两条条目为什么放在一起：owner 管"要不要人评审"，凭证管"能不能改"。
3. **报错形态可用来定位**：权限没批 → `403 Resource not accessible by integration`；权限够但值不合法 → `422`。
4. **批准之前重签 token 没有用**（实测重签三次，`administration` 始终缺席）。

## 不落盘：四条可核对的硬判据

| 判据 | 命令 / 位置 | 本库实测（2026-11-20） |
|---|---|---|
| remote URL 里没有 token | `git config --get remote.origin.url` | `https://github.com/ArtomYuan/agent-ready-repo-spec.git`，干净 |
| `.git/config` 里没有凭证 | 打开 `.git/config` 搜 `://` 与 `AUTHORIZATION` | 同上：token 走一次性 `http.extraheader`，不写进 remote |
| 仓库里没有 `.env` / 凭证文件入库 | `git ls-files` 搜 `env` / `token` / `secret` / `pem` | **0 命中**（2026-11-23 复测；此前唯一命中 `spec/rules/governance/credentials.md` 是本页旧名，已随 2.0.0 重构并入本文件） |
| 日志与 PR 描述里没有 token 明文 | 搜 `ghs_` / `github_pat_` / `-----BEGIN` | 由评审核对；模板里也明写"绝不能把 token 拼进 remote URL（会明文落到 `.git/config`）" |

正路写法在 [templates/prompt-github-app-git.md.tmpl](../../../templates/prompt-github-app-git.md.tmpl)：
token 走环境变量（`GH_TOKEN` 只对 `gh` 生效，原生 git 不认），git 侧用一次性 header
`git -c "http.extraheader=AUTHORIZATION: basic <base64('x-access-token:'+$GH_TOKEN)>" push …`，用完主动撤销。

## 常见误判

| 误判 | 为什么错 | 正确做法 |
|---|---|---|
| "有 `CODEOWNERS` 文件 = 有 owner 区分" | 全部路径指向同一个人时，文件只描述了一个人 | 判据是"治理面指向与业务代码不同的人/团队" |
| "开了 `CODEOWNERS` 就有 code owner 评审" | 不开 `Require review from Code Owners`，它不阻断任何东西 | 回读 ruleset 里那个开关 |
| "`enforce_admins = true` 了，门禁就严了" | 批准数为 0 且 code owner 评审未开时，同一个身份仍可自提自合 | 三样一起看：批准数、code owner 开关、必需检查 |
| "在 App 设置里勾掉权限 = token 就没那项权限了" | 决定 token 能力的是 installation 批准集 | 每次改完回读 `token.permissions` |
| "最小权限 = 少勾几项" | 判据是**可回读的实际权限集**，不是申请意图 | 只给 `contents:write` / `pull_requests:write` / `issues:write`，并回读确认 |
| "token 不落盘 = 没写进代码文件" | remote URL、`.git/config`、CI 日志、PR 描述都算落盘 | 走环境变量或 `http.extraheader`，用完撤销 |
| "本库没做到 owner，所以这条判据太严" | 判据本身成立，做不到的是组织规模；规范允许偏离，不允许把偏离写成达标 | 记进采用记录 + Release 已知问题 |

## 条目

### 治理面有独立 owner，且 agent 不能自行修改

`governance/owner` · L3 · should · 旧 `R044`

**为什么。** `AGENTS.md`、`.github/workflows/`、`CODEOWNERS` 是"规则本身"。谁能改它们，谁就能改自己的权限边界；`CODEOWNERS` 只有一行 `*` 等于没有区分。

**怎么做。** `CODEOWNERS` 给 `/AGENTS.md`、`/.github/`、（若存在）`/.claude/` 各单独一行；ruleset 开 `Require review from Code Owners`——**不开它就只是一份索引，不指派任何人**；权限基线里 deny 掉这些路径的 `Edit`。

### agent 使用的凭证是最小权限，且不落盘

`governance/credentials` · L2 · should · 旧 `R062`

**为什么。** agent 会被仓库内容影响（见 `R045`），它手里的凭证就是爆炸半径。一个 repo admin 的 classic token 被写进日志或 remote URL，等于把整仓交出去。本库有 [templates/prompt-github-app-git.md.tmpl](../../../templates/prompt-github-app-git.md.tmpl) 讲怎么配 App 与 git 身份，却没有条目要求"必须最小权限"。

**怎么做。** 用 GitHub App 或 fine-grained PAT，只给 `contents:write` / `pull_requests:write` / `issues:write`，不给 admin；token 走环境变量或 `http.extraheader`，**不进 remote URL、不进 `.git/config`、不进日志**；用完主动撤销。

## 相关

- [提交规则](commits.md) — 提交层归属线索：trailer 与它的两种坏法
- [PR 里的 agent 参与](pull-requests.md) — 评审层的批准与复核人；"谁能改 ruleset"为什么必须写下来
- [协作文件规则](../documents/collaboration.md) — `CODEOWNERS` 文件本身的判据（存在性与写法）
- [分支保护规则](../settings/branch-protection.md) — ruleset 六项、`bypass_actors`、必需检查名
- [CI 规则](../settings/ci.md) — workflow 的 `permissions` 与 Action 固定 SHA（同一件事的另一端）
- [权限 deny 基线](../agent-config/permissions.md) — 第三道门：agent 动手之前的本地拦截
- [采用记录规则](../adoption/record.md) — 偏离 owner 判据时，理由与"谁能改 ruleset"的落点
- [内容规则](../release/content.md) — `release/self-noncompliance`（旧 `R069`）：不合格要在 Release 里自曝
- [guide/05 · Agent 参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md) — 治理面单独 owner、反例表、自锁附录
- [ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md) · [ADR-0011](../../../docs/adr/0011-github-management-rules.md) — 这两条条目的由来与代价
- [分支保护实测](../../../docs/evidence/2026-11-17-protection-probe.md) · [App 权限传播实测](../../../docs/evidence/2026-11-18-github-app-permission-propagation.md) — 本页所有数值的出处
