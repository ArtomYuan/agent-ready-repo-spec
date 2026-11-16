---
paths:
  - "rules/**"
  - "spec/**"
  - "checker/**"
---

# 规则与引擎改动规则

- **只改 `rules/rules.json`**。`spec/RULES.md` 是生成物，手改会被 `gen-rules-doc.ps1 -Check` 抓出来。
- 新规则必须同时给出 `rationale`（为什么值得一条规则）与 `fix`（一句话怎么改）。
- 判定条件变化 = 语义变化 → 升 `specVersion` + 写 `CHANGELOG.md`。
- 新增 `check.kind` 必须：在引擎 `switch` 里实现、在 `tests/selftest.ps1` 加 fixture、写一条 ADR。
- **不允许**为了某个具体仓库放宽规则；规则要能解释成一句自然语言。
- 正则避免嵌套量词（`(a+)+` 这类），避免在不可信仓库上触发灾难性回溯。
- 规则 ID 不复用、不删除；废弃用 `"deprecated": true`，保留历史报告可对齐。
