# settings.local.json 未被提交

> 档位 `L2` · 级别 `must` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

个人覆盖含本机路径与令牌，提交即泄露。

## 怎么做

从索引移除：git rm --cached .claude/settings.local.json，并写进 .gitignore。

## 讲解

[guide/02-目录结构](../../../guide/02-目录结构.zh-CN.md)

