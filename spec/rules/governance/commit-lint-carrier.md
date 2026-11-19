# 提交规范有机器执行载体（可选升级）

> 档位 `L2` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

GitHub 自家仓库大多不强制提交格式（actions/checkout 只在 CONTRIBUTING 里给一条外部链接），Claude Code 也不内置格式校验——所以这条不是行业基线，而是**可选升级**：只有当你希望按前缀自动生成 CHANGELOG / 自动发版时才需要它。

## 怎么做

加 commitlint 配置（extends @commitlint/config-conventional），并在 CI 或 commit-msg hook 里跑起来；不需要自动化的仓库可以不管这条。

## 讲解

[guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

## 跨板块

本条同时被下列章节解释（**只引用，不复制判据**）：

- [guide/06-信息该放哪](../../../guide/06-信息该放哪.zh-CN.md)

