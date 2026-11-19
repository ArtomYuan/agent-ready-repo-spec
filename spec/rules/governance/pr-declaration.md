# PR 层面声明 agent 参与（工具 / 是否人工复核）

> 档位 `L3` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

`R029` 的 trailer 是**提交层**线索，PR 描述里的声明是**评审层**线索——reviewer 在决定"这个 diff 该怎么读"之前就该看到它。`kubernetes/kubernetes` 走的是相反路线：禁止 `Co-authored-by`，改为在 PR 里声明 AI 使用并要求人类作者负全责。**两种文化都成立**，所以这条只到 `may`，且不推翻 `R029`。

## 怎么做

PR 模板加一行：`本次是否有 agent 参与：<工具/模型> · 人工复核人：<@user>`。与 `R029` 组合：提交层与评审层各留一条线索。分歧记录见 [2026-11-18 采样 §三](../../../docs/evidence/2026-11-18-agent-docs-sampling.md)。

## 讲解

[guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

