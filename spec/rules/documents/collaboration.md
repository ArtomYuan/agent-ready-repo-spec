# 协作面四件套规则

> 板块 `documents` · 本页承载 4 条条目：`documents/contributing`（L1 · may · 旧 `R010`）·
> `documents/codeowners`（L1 · should · 旧 `R011`）· `documents/pr-template`（L1 · should · 旧 `R012`）·
> `documents/issue-template`（L1 · should · 旧 `R013`）
> 讲解与采样依据见 [guide/01 · 该有什么文档](../../../guide/01-该有什么文档.zh-CN.md)。
> 通用术语与具体文件名的对应见 [机制对照表](../../mechanism-map.md)（附录，非规范）。

## 一句话

这四份文件不是"欢迎贡献"的装饰，它们各拦一种具体失败：**没人知道怎么提**（CONTRIBUTING）、
**关键路径没人看**（CODEOWNERS）、**描述质量靠自觉**（PR 模板）、**issue 收上来是散的**（Issue 模板）。
四件套还有个共同点：**放错位置等于没写**——所以先讲位置，再讲内容。

## 位置与后果

GitHub 只认固定位置的**文件**，不认"目录"：

| 文件 | 被识别的位置 | 缺了 / 放错的后果 |
|---|---|---|
| `CONTRIBUTING` | 根 / `.github/` / `docs/`，不区分大小写，`.rst` 也认 | 没有"贡献前请读"提示；只放 `contributing/` 目录 → 平台不认，**目录本身不算** |
| `CODEOWNERS` | `.github/` / 根 / `docs/` | 评审靠 @ 人，容易漏 |
| `PULL_REQUEST_TEMPLATE.md` | `.github/` 或根 | 描述质量靠自觉 |
| `ISSUE_TEMPLATE/*.yml` | **只能** `.github/ISSUE_TEMPLATE/` | 不出现模板选择器；社区档案不打勾 |

**CONTRIBUTING 为什么只是 `may`**：十仓实测里根目录有它的只有 **6/10**，而且它是四件套里唯一一份
**agent 不会自动加载**的——agent 工具的默认加载链里没有它。要 agent 遵守，就在 `AGENTS.md` 里写一句指针
（`cli/cli`：`Read CONTRIBUTING, the canonical contribution policy.`）。它该有内容时必含四样：分支模型、
提交格式、PR 流程、**评审 SLA（写数字）**——"尽快回复"= 没有承诺。

## CODEOWNERS 是开关，不是名单

| 条件 | 不满足时 |
|---|---|
| 覆盖关键路径：工具专属资产目录、`.github/workflows/`、`AGENTS.md`、关键业务目录 | 只有 `*` 一条 → 没有分级，改 CI 和改错别字走同一条路 |
| 开启 `Require review from Code Owners` | **写得再漂亮也只是注释**，不会有人被强制指派 |

owner **必须是人类账号或团队，不能是 bot 或 agent**：闸门由被闸门约束的对象持有钥匙，闸门就消失了
（[templates/CODEOWNERS.tmpl](../../../templates/CODEOWNERS.tmpl) 第一行注释就是这条）。

**本库自己就是"形式合规、闸门无效"的样本**：`.github/CODEOWNERS` 五条规则（`*`、`/spec/`、`/guide/`、
`/AGENTS.md`、`/.github/`）全指向同一个 `@ArtomYuan`——文件在、覆盖也对，但没有一条路径有独立的第二双眼睛。
这正是 `governance/owner`（旧 `R044`）在本库长期不合格的那一条，本库在 [guide/00 §6](../../../guide/00-接入决策.zh-CN.md)
与 CHANGELOG `1.5.0` 节自曝过它（当时 `release/self-noncompliance` 还不存在，未走 Release「已知问题」落点）。
owner 归属与 `Require review from Code Owners` 开关见 [治理面归属规则](../governance/ownership.md)，
ruleset 六项见 [分支保护规则](../settings/branch-protection.md)。

## PR 模板：字段要糊不过去

判据是"模板是唯一能稳定拿到的结构化信息"。但**模板本身不产生信息**——本库自审实测：`#3`–`#6` 四个 PR
正文按 `#3`→`#6` 分别是 165 / 159 / 163 / 163 个字符，全是同一套模板套话，信息量≈0
（[本库自审](../../../docs/evidence/2026-11-17-repo-self-audit.md) §2）。所以：**能被套话填满的字段等于没有字段**。
本库 `.github/PULL_REQUEST_TEMPLATE.md` 里两处设计糊不过去：「怎么验证的」配注释"贴真实输出或可复现步骤，不要写'已测试'"
——真实输出必须跑一遍才有；「非目标」配注释"不写，下一个人会当成漏了"——强迫作者交代刻意没做的部分。

**自检清单该含什么**是 `writing/` 的判据，见 [PR 模板写法规则](../writing/pr-template.md)；
提交信息格式与 agent 归属见 [提交规则](../governance/commits.md)。

## Issue 模板：打勾的是 frontmatter

社区档案那个勾判的是**机器能读到的字段**，不是模板写得好不好。一个容易混的点：`config.yml` 的
`contact_links` **不产生模板**，它只在模板选择器旁边加"去哪问"的链接（本库用它把"安全漏洞（私密）"
和"使用问题 / 讨论"分流走）。

## 常见误判

| 误判 | 为什么错 |
|---|---|
| "把贡献指南写成 `contributing/` 目录，内容更全" | 平台不认目录，必须有固定位置的入口文件指过去 |
| "CODEOWNERS 加了，评审就有了" | 不开 `Require review from Code Owners`，它只是一份注释 |

## 条目

### 存在 CONTRIBUTING（人类读者）

`documents/contributing` · L1 · may · 旧 `R010`

**为什么。** 这份文件是写给人看的：agent 不会自动加载它（agent 工具的默认加载链里没有 CONTRIBUTING），GitHub 也只认固定位置的入口文件（根 / .github / docs，文件名大小写不敏感，.rst 也认，`contributing/` 目录本身不算）。所以它是公开库的常见习惯，不是 agent 就绪的必要条件。

**怎么做。** 在根或 .github/ 放一个 CONTRIBUTING.md 作入口，详细内容放 docs/ 或 contributing/ 目录并在入口里指过去；私有库且不收外部 PR 可以不管。

### 存在 CODEOWNERS

`documents/codeowners` · L1 · should · 旧 `R011`

**为什么。** 按路径自动指派评审人，是 agent 改动的第一道人工闸门；需同时开启 Require review from Code Owners。

**怎么做。** 加 CODEOWNERS，覆盖工具专属资产目录（若存在）、.github/workflows/、AGENTS.md 与关键业务目录。

### 存在 PR 模板

`documents/pr-template` · L1 · should · 旧 `R012`

**为什么。** 模板是唯一能稳定拿到的结构化信息（改了什么/为什么/怎么验证的）。

**怎么做。** 加 .github/PULL_REQUEST_TEMPLATE.md，含改动、理由、影响面、验证输出、自检清单。

### Issue 模板带合法 frontmatter

`documents/issue-template` · L1 · should · 旧 `R013`

**为什么。** 只有 .github/ISSUE_TEMPLATE/ 下带 name + description（或 name + about）的模板才会被社区档案打勾。

**怎么做。** 给每个 .yml 模板补 name: 与 description:；.md 模板用 name + about。

## 相关

- [三份基础文件规则](essentials.md) · [信任与举报规则](trust.md)
- [PR 模板写法规则](../writing/pr-template.md) — 自检清单该含什么
- [治理面归属规则](../governance/ownership.md) — CODEOWNERS 的 owner 该归谁
- [提交规则](../governance/commits.md) · [分支保护规则](../settings/branch-protection.md)
- [机制对照表](../../mechanism-map.md) — 通用术语 ↔ 具体文件名（附录，非规范）
- [guide/01 · 该有什么文档](../../../guide/01-该有什么文档.zh-CN.md) — 第一档清单与识别位置
