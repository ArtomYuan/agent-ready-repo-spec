# workflow 显式声明 `permissions`，第三方 Action 固定到 commit SHA

> 档位 `L2` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

默认 `GITHUB_TOKEN` 的权限常常比需要的宽，而 agent 提的 PR 会带着这些权限跑起来。tag 可以被移动、SHA 不能——固定到 tag 等于把供应链交给一个可改写的指针。本库的 `.github/workflows/docs.yml` 两个 Action 都固定到 SHA，注释里写了理由，但**此前没有任何条目要求别人也这么做**：实践与规则脱节。

## 怎么做

每个 workflow 顶部写 `permissions: contents: read`，按 job 再单独放大；`uses:` 一律写 40 位 SHA 并在注释里标对应 tag；`pull_request_target` 若必须用，单独写一条 ADR 说明为什么。官方依据：[Assigning permissions to jobs](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs)。

## 讲解

[guide/07-该开哪些设置](../../../guide/07-该开哪些设置.zh-CN.md)

