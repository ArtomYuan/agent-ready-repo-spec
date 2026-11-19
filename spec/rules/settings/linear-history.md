# 最近提交是线性历史（无 merge commit）

> 档位 `L3` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

线性历史让 revert、cherry-pick、审计都变简单；merge commit 会把一条 PR 的变化混进两条父提交，出问题时难以定位与回滚。

## 怎么做

仓库设置启用 Squash merge 或 Rebase merge，关闭 Merge commit；已存在的 merge 不必重写。

## 讲解

[guide/07-该开哪些设置](../../../guide/07-该开哪些设置.zh-CN.md)

