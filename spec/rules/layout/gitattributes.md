# 存在 .gitattributes（Windows 协作必查）

> 档位 `L1` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

不处理行尾与二进制/LFS，跨平台协作会产生整文件 diff 与损坏的二进制。

## 怎么做

加 .gitattributes：* text=auto eol=lf，图片/字体标 binary。

## 讲解

[guide/02-目录结构](../../../guide/02-目录结构.zh-CN.md)

