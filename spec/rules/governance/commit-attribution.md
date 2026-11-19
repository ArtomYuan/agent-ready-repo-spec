# 保留 agent 提交归属（未关闭 attribution，与工具无关）

> 档位 `L2` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

Claude Code 默认给提交加 git trailer（`Co-Authored-By: <model> <noreply@anthropic.com>`），这是 agent 参与最便宜的审计手段；把它关掉，事后就分不清哪次提交是模型写的。

## 怎么做

删掉 attribution 的 false / 空字符串；要改文案就保留 trailer，例如 `attribution.commit: "Co-Authored-By: Claude <noreply@anthropic.com>"`。

## 讲解

[guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

