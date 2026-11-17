# ADR-0006：以 GitHub Action 作为分发形态

- 状态：Superseded by [ADR-0009](0009-spec-only-no-tooling.md)（2026-11-17）：Action 已删除
- 日期：2026-11-17
- 决策者：@ArtomYuan
- 相关：[README](../../README.md) · [guide/00-接入决策.md](../../guide/00-接入决策.md) · action.yml

## 背景

现在的接入方式是"克隆本仓库 + 跑脚本"：

```bash
git clone <repo> .spec && pwsh .spec/checker/spec-check.ps1 -Target .
```

对一个 Node / Python 项目来说，这条命令里有两处摩擦：

1. 要把别人的仓库拉进工作区（或额外 checkout 一次）；
2. 要在自己的 CI 里写多行脚本。

Qwen 的外部评审也指出了同一点：**"跑一次体检"的门槛应该降到贴一个 yml。**

## 选项

1. **保持现状**（文档教人怎么写多行 CI）。零成本，但接入摩擦一直在。
2. **发布 npm / PyPI 包**。需要运行时与包管理，与本项目"零依赖"的定位冲突。
3. **做成 composite GitHub Action**（`uses: <owner>/<repo>@<ref>`）。调用方只需一行；GitHub 会把 action 拉进 `github.action_path`，不需要额外 checkout。

## 结论

选 3，并用**两种引用方式**并存：

| 方式 | 写法 | 用途 |
|---|---|---|
| 快速试用 | `uses: ArtomYuan/agent-ready-repo-spec@v1` | 一行接入；`v1` 是随 minor 移动的 tag |
| 生产使用 | `uses: ArtomYuan/agent-ready-repo-spec@<commit-sha>` | 与本库 `docs/guides/use-in-ci.md` 的"固定 SHA"建议一致 |

**这是刻意的取舍**：便利性靠移动 tag，安全性靠 SHA，文档里明说两者的区别，不假装只有一个正确答案。

## 后果

**正面**

- 接入从"两条命令 + 多行 yml"变成一行 `uses`；
- 与本库对 CI 的建议（固定 SHA、只读 token）自洽；
- 不引入任何包管理，仍是零依赖。

**负面**

- 多一个需要维护的公开接口：`action.yml` 的 inputs 一旦改名就是破坏性变更；
- `v1` 是移动 tag，**它指向哪里随时会变**——这正是我们要提醒使用者固定 SHA 的原因；
- composite action 在调用方跑的是 `pwsh`，所以要求 runner 上有 PowerShell（三大平台的 GitHub 托管 runner 都预装）。

**边界**：Action 只做"跑一次体检"，不做修复、不改目标仓库——与 [ADR-0002](0002-checker-is-read-only.md) 一致。

## 复审

2027-01-31，或 `action.yml` 的 inputs 需要破坏性调整时。

## 相关

- 首次发布 tag：`v1`（指向含 `action.yml` 的提交）
- 使用文档：`README` 的 "Use as a GitHub Action" 一节
