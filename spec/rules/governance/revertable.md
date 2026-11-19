# agent 的改动可单独 revert

> 档位 `L3` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

L3 的判据是"可拒绝、可回滚、不腐烂"，但"可拒绝"有闸门（`R060`、`R043`），**"可回滚"此前没有任何条目**。一个 PR 混多个目的时，revert 等于把好的部分一起丢掉。

## 怎么做

一个 PR 只做一件事（[spec/agent-playbook.md](../../agent-playbook.md) §3）；只允许 squash + 线性历史（`R051`）；PR 描述里写清"怎么回滚"。

## 讲解

[guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

