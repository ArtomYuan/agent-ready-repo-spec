# agent 使用的凭证是最小权限，且不落盘

> 档位 `L2` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

agent 会被仓库内容影响（见 `R045`），它手里的凭证就是爆炸半径。一个 repo admin 的 classic token 被写进日志或 remote URL，等于把整仓交出去。本库有 [templates/prompt-github-app-git.md.tmpl](../../../templates/prompt-github-app-git.md.tmpl) 讲怎么配 App 与 git 身份，却没有条目要求"必须最小权限"。

## 怎么做

用 GitHub App 或 fine-grained PAT，只给 `contents:write` / `pull_requests:write` / `issues:write`，不给 admin；token 走环境变量或 `http.extraheader`，**不进 remote URL、不进 `.git/config`、不进日志**；用完主动撤销。

## 讲解

[guide/05-Agent参与怎么管理](../../../guide/05-Agent参与怎么管理.zh-CN.md)

## 跨板块

本条同时被下列章节解释（**只引用，不复制判据**）：

- [guide/04-Agent怎么用](../../../guide/04-Agent怎么用.zh-CN.md)

