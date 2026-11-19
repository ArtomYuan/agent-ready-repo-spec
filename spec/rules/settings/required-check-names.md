# 必需检查的名字与 workflow 的 job 名逐字一致

> 档位 `L3` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

ruleset 里存的是**字符串**，不是引用。job 改名或删掉，那一项就永远停在 `Expected — Waiting for status to be reported`，`main` 从此不可合并——**本仓库真的发生过一次**，恢复要靠改 ruleset。

## 怎么做

顺序固定：先加新名字的 job → 改 ruleset → **下一个 PR** 再删旧 job。把当前保护配置写进 `AGENTS.md`，让所有人在动 CI 之前先看见这张表。事故复盘：[ADR-0010](../../../docs/adr/0010-required-checks-self-lock.md)。

## 讲解

[guide/07-该开哪些设置](../../../guide/07-该开哪些设置.zh-CN.md)

