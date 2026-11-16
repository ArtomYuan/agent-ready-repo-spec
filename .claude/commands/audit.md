---
description: 对指定仓库跑一次规范体检并给出优先级结论
argument-hint: <path> [level]
allowed-tools: Bash(pwsh *), Read
---

对目标仓库 `$1` 做 agent-ready-repo-spec 体检，等级 `$2`（缺省 3）。

步骤：

1. 跑 `pwsh ./checker/spec-check.ps1 -Target $1 -Level ${2:-3} -Format json`。
2. 读 JSON：先看 `summary.must.fail`，再看 `achievedLevel`，最后只列 must/should 的 FAIL。
3. 输出三段式结论：达成等级 / 硬伤 / 阻断下一级的具体项 + 建议顺序。
4. 不要自动修改目标仓库。要修先问我。

规则说明见 `spec/RULES.md`；这条命令的判据与 skill `audit-repo` 一致。
