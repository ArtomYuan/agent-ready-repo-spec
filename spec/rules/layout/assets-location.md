# 跨工具 agent 资产放 `.github/`，工具独占的放工具目录，且只有一处事实源

> 档位 `L3` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

`cli/cli` 与 `microsoft/vscode` 把 agents / skills 放 `.github/`，Claude 那套放 `.claude/`。两边各存一份就是两个事实源，生效哪个看运气。

## 怎么做

一句话判据：**只有某个工具用 → 那个工具的目录；可能被多个工具用 → `.github/`**；另一处只放指针。详见 [guide/02 §5](../../../guide/02-目录结构.zh-CN.md)。

## 讲解

[guide/02-目录结构](../../../guide/02-目录结构.zh-CN.md)

