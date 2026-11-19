# 若用 hooks：hook 脚本使用 exit 2 阻塞

> 档位 `L3` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

阻塞类 hook 不收 exit 2 就等于没检查：exit 0 只进日志，exit 1 是非阻塞错误。

## 怎么做

违规分支改为写 stderr 后 exit 2。

## 讲解

[guide/04-Agent怎么用](../../../guide/04-Agent怎么用.zh-CN.md)

