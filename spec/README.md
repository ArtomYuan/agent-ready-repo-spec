# 规范正文

本目录说明**怎么读这套规范**。逐条规则见 [RULES.md](RULES.md)（由 `rules/rules.json` 生成，勿手改）。

## 一个仓库的四个成熟阶段

| 级别 | 一句话判据 | 通过它意味着 |
|---|---|---|
| **L0** | 人和 agent 都能在 30 秒内接手 | 有 README / AGENTS.md / .gitignore / LICENSE，且 CI 能跑 |
| **L1** | 外部贡献者不会问“我该怎么提” | 有 CONTRIBUTING / CODEOWNERS / PR&Issue 模板 / CHANGELOG |
| **L2** | 有事能查、有决策能追溯 | 有 SECURITY / docs 地图 / 至少一条 ADR / agent 权限基线 |
| **L3** | agent 的改动可拒绝、可回滚、不腐烂 | AGENTS.md 体积与结构合格、hook 引用有效、文档引用不失效 |

**级别是累积的**：L2 隐含 L0+L1。`achievedLevel` 取“所有 must+should 都通过”的最高级别。

## 三档严重度

| 严重度 | 含义 | 典型 |
|---|---|---|
| `must` | 缺了就是硬伤，会在几周内咬人 | 提交了 `settings.local.json`、`.gitignore` 没排除个人配置 |
| `should` | 该有；没有会让协作或治理变形 | 无 CODEOWNERS、无 ADR、`permissions.deny` 为空 |
| `may` | 加分项，视项目规模取舍 | 无 CODE_OF_CONDUCT、无 `.editorconfig`、无 `.gitattributes` |

`may` **不阻断** `achievedLevel`。这是刻意的：小项目不该被"加分项"判红。

## 判定方式（13 种 `check.kind`）

见 [architecture/checker.md](../docs/architecture/checker.md) 的表。要点：

- 判定全部是**结构性**的：文件在不在、字段有没有、行数超没超、引用还存不存在。
- **没有**“代码质量”“测试覆盖率”这类需要主观判断的规则——那种规则会立刻被绕过。
- **没有**“必须用某家 CI”——规范只管可验证的痕迹，不管工具选型。

## 命令行接口

```
spec-check.ps1 -Target <path> [-Level 0..3] [-Format text|json|md] [-FailOn must|should|none]
```

| 退出码 | 含义 |
|---|---|
| `0` | 按 `-FailOn` 判定通过 |
| `1` | 有未通过项 |
| `2` | 运行错误（目标不存在、规则文件无法解析） |

## 版本策略

- `specVersion` 遵循 SemVer。
- **新增 `may`/`should` 规则** → minor。
- **把规则改成 `must`，或收紧判定条件** → major（下游会突然变红）。
- 旧规则**只废弃不删除**（`"deprecated": true`），保证历史报告还能对齐。

## 规范不覆盖什么

以下内容是有意排除的，因为无法稳定判定，且容易变成走过场：

- 提交信息是否符合某个格式（应由 commitlint 在 CI 里管）
- 测试覆盖率阈值
- 代码风格
- “文档写得好不好”
- 用了哪个 CI / 哪个模型 / 哪个 agent 工具
