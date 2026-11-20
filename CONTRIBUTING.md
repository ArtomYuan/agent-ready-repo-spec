# 贡献指南

## 什么样的贡献最有价值

| 类型 | 例子 | 需要的材料 |
|---|---|---|
| **规则纠错** | 某条清单条目太严 / 太松 / 根本无法判定 | 一个真实仓库的反例，说明为什么这条判据不成立 |
| **新条目** | 发现某个反复出现的问题没有被覆盖 | 条目 + `id` + 级别 + 判据 + "为什么" + "怎么改" |
| **章节补充** | 某个判据只有结论、没有例子 | 正例与反例各一个 |
| **模板改进** | 模板缺字段、或多出没人填的字段 | 直接改，PR 里说明取舍 |

**不接受**：

- 为了让某个仓库"过关"而放宽判据；
- 给这个库加入可执行物或规则校验（脚本、依赖清单、对 `rules/README.md` 的机器校验）——见 [ADR-0009](docs/adr/0009-spec-only-no-tooling.md)；
- 只改中文或只改英文（两版必须同一 PR 内同步，见 [ADR-0008](docs/adr/0008-bilingual-equal-status.md)）。

## 分支与提交

> **main 受保护**：任何变更——人写的、agent 写的都一样——必须走 PR。
> 理由见 [docs/adr/0004-all-changes-via-pr.md](docs/adr/0004-all-changes-via-pr.md)。

```
main                受保护，只能通过 PR 合入
feat/<slug>         新条目 / 新章节
fix/<slug>          改判据、修表述
docs/<slug>         纯文档
chore/<slug>        模板、杂项
```

提交信息用 Conventional Commits，scope 取 `spec` / `guide` / `templates` / `docs`：

```
feat(spec): 新增 R042（AGENTS.md 声明输出语言）
fix(guide): 03 章的反例表格与正文不一致
```

## 改规则的流程

1. 改 **[spec/rules/](spec/rules/README.md)** 里那条规则自己的文件（**判据正文只在那里**），
   再同步 `spec/rules/README.md` 的对应行（判据句与 H1 逐字一致、级别一致）。不要再引入第二份清单。
2. 若判据变严或条目升级为 `must`：升 `specVersion`（[spec/README.md](spec/README.md) 有策略）。
3. 中英两版相关章节同步更新（`guide/*.md` 与 `guide/*.zh-CN.md`）。
4. 更新 `CHANGELOG.md`。
5. 若这是一条"为什么这么定"的决策（而非单纯修错），补一条 ADR。

## 发布

判据在 [`spec/rules/release/`](spec/rules/README.md)（8 条），写法在 [guide/06 §2](guide/06-信息该放哪.zh-CN.md)。这里只放**顺序**：

1. 一个提交把 `CHANGELOG.md` 的 `[Unreleased]` 转成版本节，上面留一个空的 `[Unreleased]`；
   版本节标题下写一句**升了哪一位、为什么**（`release/version-bump-why`），例：`1.6.0 → 2.0.0：规则按板块分主题文档、ID 换成 板块/主题，引用失效属破坏性变更 → major`；
2. 同步三处会跟着变的声明：`spec/README.md` 的"当前 `specVersion`"、`README`/`README.zh-CN`/`AGENTS.md`
   的条目数、`.github/ISSUE_TEMPLATE/bug.yml` 的占位版本。**漏一处，首页就开始说谎**；
3. 合并；
4. 在**合并后的那个提交**上打 tag——不是它前面那个；
5. 建 Release，四节：升级注意 / 新增·变更·修复 / 已知问题 / 校验。
   「已知问题」里必须列出**本库自己不合格**的条目（`release/self-noncompliance`）；
6. 正文里不写会失效的计数和状态句（`release/no-stale-numbers`）。本库一周内踩了三次，见 [ADR-0012](docs/adr/0012-release-notes-spec.md)。

**移动 tag 是破坏性变更**：优先发更正版本；确实要动，按 `release/moving-tags` 留痕（旧 SHA / 新 SHA / 原因），
被取代的 tag 标 *Superseded* 不删（`release/superseded-tags`）。

## PR

用 [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)。
必须填"怎么验证的"，并说明你核对了清单里的哪几条。

## 评审 SLA

维护者在 **3 个工作日**内给出第一次回应（同意 / 需要修改 / 拒绝并说明理由）。
超时无人回应，可以在 PR 里 @ 一次；仍无回应视为维护者失职，允许 fork 自行维护。

## 行为准则

参与即表示同意 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。