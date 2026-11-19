# 若用 Copilot：仓库级指令文件存在，且不与 `AGENTS.md` 双写

> 档位 `L3` · 级别 `may` —— 本文件是判据正文的**唯一归属地**；[规则索引](../README.md) 只做导航。

## 为什么

实测里 `.github/copilot-instructions.md` 在头部仓库是主战场：`microsoft/vscode` 14.5 KB、`denoland/deno` 12.3 KB、`supabase/supabase` 6.5 KB。本库的 `guide/02` 只在表格里提了一句，清单里**零条**——自己的证据没有转化成规则。

## 怎么做

细则只放一处（`AGENTS.md` 或 `.github/copilot-instructions.md`），另一处只放指针；分主题指令用 `.github/instructions/*.instructions.md` + `applyTo`。证据：[2026-11-18 采样](../../../docs/evidence/2026-11-18-agent-docs-sampling.md)。

## 讲解

[guide/04-Agent怎么用](../../../guide/04-Agent怎么用.zh-CN.md)

