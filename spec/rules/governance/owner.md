# 治理面有独立 owner，且 agent 不能自行修改

> 档位 `L3` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

`AGENTS.md`、`.github/workflows/`、`CODEOWNERS` 是"规则本身"。谁能改它们，谁就能改自己的权限边界；`CODEOWNERS` 只有一行 `*` 等于没有区分。

## 怎么做

`CODEOWNERS` 给 `/AGENTS.md`、`/.github/`、（若存在）`/.claude/` 各单独一行；ruleset 开 `Require review from Code Owners`——**不开它就只是一份索引，不指派任何人**；权限基线里 deny 掉这些路径的 `Edit`。

## 讲解

[guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

