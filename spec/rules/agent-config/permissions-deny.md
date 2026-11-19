# 若用 Claude Code：permissions.deny 非空

> 档位 `L2` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

没有 deny 就是全开；密钥路径与破坏性命令必须先封。

## 怎么做

至少 deny：Read(./.env)、Read(./secrets/**)、Bash(rm *)、Bash(git reset *)。

## 讲解

[guide/04-Agent怎么用](../../../guide/04-Agent怎么用.zh-CN.md)

