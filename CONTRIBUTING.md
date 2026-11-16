# 贡献指南

## 什么样的贡献最有价值

| 类型 | 例子 | 需要的材料 |
|---|---|---|
| **新规则** | 发现某个反复出现的仓库问题没有被覆盖 | `rules.json` 条目 + `rationale` + `fix` + fixture |
| **规则纠错** | 某条规则误报/漏报 | 一个能复现的最小目录结构 |
| **新 `check.kind`** | 现有 13 种表达不了 | 引擎实现 + `tests/selftest.ps1` 用例 + ADR |
| **文档** | 例子跑不通、表述有歧义 | 直接改，PR 里说明 |

**不接受**：为了让某个仓库“过关”而放宽规则；给检查器加第三方依赖；把规则判定藏进脚本黑盒（必须能在 `rules.json` 里读懂）。

## 分支与提交

> **main 受保护**：任何变更——人写的、agent 写的都一样——必须走 PR 并通过 CI。
> agent 的发布工具是 `tools/publish-pr.ps1`（自动建分支、开 PR、等检查、squash 合并）。
> 理由与破窗流程见 [docs/adr/0004-all-changes-via-pr.md](docs/adr/0004-all-changes-via-pr.md)。

```
main                受保护，只能通过 PR 合入
feat/<slug>         新规则 / 新能力
fix/<slug>          修误报、修 bug
docs/<slug>         文档
chore/<slug>        构建、模板、杂项
```

提交信息用 Conventional Commits，scope 取 `rules` / `checker` / `spec` / `docs` / `templates`：

```
feat(rules): 增加 R041 检查 docs/index.md 的死链
fix(checker): md-refs-exist 忽略纯扩展名 token
```

## 改规则的流程

1. 改 `rules/rules.json`（**只改这里**）。
2. `pwsh ./checker/gen-rules-doc.ps1` 重新生成 `spec/RULES.md`。
3. 若是新 `check.kind`，在 `tests/selftest.ps1` 加 fixture 与断言。
4. `pwsh ./tests/selftest.ps1` 全绿。
5. `pwsh ./checker/spec-check.ps1 -Target .` 自己体检自己，**L3 必须全绿**。
6. 更新 `CHANGELOG.md`；判定条件变化则升 `specVersion`。

## PR

用 [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md)，必须填“怎么验证的”并贴真实输出。

## 评审 SLA

维护者在 **3 个工作日**内给出第一次回应（同意 / 需要修改 / 拒绝并说明理由）。
超时无人回应，可以在 PR 里 @ 一次；仍无回应视为维护者失职，允许 fork 自行维护。

## 行为准则

参与即表示同意 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。
