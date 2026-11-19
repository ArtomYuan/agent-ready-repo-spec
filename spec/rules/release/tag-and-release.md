# 每个发布版本都有 tag 和 Release 页，tag 锚在发布提交上

> 档位 `L2` · 级别 `should` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

`SECURITY.md` 承诺"只对最新 `specVersion` 提供修复"——没有一个可锚定的 tag，这句就是空话，下游也无从固定引用。本库曾只有 `v1`，指向含 `checker/` 的旧树。

## 怎么做

发版 = 一个把 `[Unreleased]` 转成版本节的提交 → 在**该提交**上打 tag → 建 Release。三件产物的分工见 [guide/06](../../../guide/06-信息该放哪.zh-CN.md) §2。

## 讲解

[guide/06-信息该放哪](../../../guide/06-信息该放哪.zh-CN.md)

