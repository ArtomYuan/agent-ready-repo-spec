# `main` 受保护：必须 PR + 必需检查 + 禁止删除与强推，且对 admin 也生效

> 档位 `L2` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

这是唯一真正**硬**的边界：`AGENTS.md` 里写的"禁区"是提示，分支保护才是闸门。agent 若能改 CI，就等于能给自己放行。反面教材本库亲身踩过——必需检查名写错导致 `main` 永久不可合并（[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md)），说明这道门配错的代价是双向的。

## 怎么做

用 ruleset（不要用旧版分支保护）：`deletion` + `non_fast_forward` + `pull_request`（≥1 人工批准、只允许 squash）+ `required_status_checks` + `required_linear_history`；`bypass_actors` 留空，让 admin 也不能绕过。当前实测值见 [guide/07](../../../guide/07-该开哪些设置.zh-CN.md)。

## 讲解

[guide/07-该开哪些设置](../../../guide/07-该开哪些设置.zh-CN.md)

## 跨板块

本条同时被下列章节解释（**只引用，不复制判据**）：

- [guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

