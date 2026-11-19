# 文档地图

本仓库有三类读者，入口分开。

## 我是人，想用这套规范

| 我想 | 去哪 |
|---|---|
| 先看看这东西讲什么 | [README.md](../README.md) |
| 知道 L0–L3 到底要求什么 | [spec/rules/README.md](../spec/rules/README.md) |
| 决定接哪一档、怎么把决定记下来 | [guide/00-接入决策.zh-CN.md](../guide/00-接入决策.zh-CN.md) |
| 写某一份具体文档 | [guide/03-文档该怎么写.zh-CN.md](../guide/03-文档该怎么写.zh-CN.md) |
| 该点哪些仓库设置 | [guide/07-该开哪些设置.zh-CN.md](../guide/07-该开哪些设置.zh-CN.md) |
| 看填好的 `AGENTS.md` 成品（两种形态） | [examples/](../examples/README.zh-CN.md) |
| 贡献一条规则或改一章 | [CONTRIBUTING.md](../CONTRIBUTING.md) |

## 我是 agent，要替人管一个库

先读 [AGENTS.md](../AGENTS.md)（本仓库的事实源），再读 **[spec/agent-playbook.md](../spec/agent-playbook.md)**（按什么顺序做）。
规则逐条在 [spec/rules/README.md](../spec/rules/README.md)。

> 这套规范**不提供检查器**，任何语言都可以自己实现对 checklist 的解析。原因见
> [ADR-0009](adr/0009-spec-only-no-tooling.md)。

## 我在看设计

| 我想 | 去哪 |
|---|---|
| 为什么这个库只有文档、不含可执行物 | [adr/0009-spec-only-no-tooling.md](adr/0009-spec-only-no-tooling.md) |
| 为什么全部变更必须走 PR | [adr/0004-all-changes-via-pr.md](adr/0004-all-changes-via-pr.md) |
| 必需检查自锁的真实事故与恢复步骤 | [adr/0010-required-checks-self-lock.md](adr/0010-required-checks-self-lock.md) |
| 为什么把"GitHub 管理面"提升成可判定条目（`R043`、`R060`–`R063`） | [adr/0011-github-management-rules.md](adr/0011-github-management-rules.md) |
| 为什么"发布物怎么写"也要进清单（`R064`–`R070`） | [adr/0012-release-notes-spec.md](adr/0012-release-notes-spec.md) |
| 为什么规则改成一条一个文件、ID 换成 `板块/主题`（2.0.0） | [adr/0013-rules-by-domain.md](adr/0013-rules-by-domain.md) |
| 中英两版谁是事实源 | [adr/0008-bilingual-equal-status.md](adr/0008-bilingual-equal-status.md) |
| **证据与实测数据** | [evidence/](evidence/)（按采集日期命名：仓库采样、本仓库自审、官方文档摘录、分支保护实测） |

历史决策（规则用 JSON、检查器只读、Action 分发）保留在 `adr/` 里，均已被 ADR-0009 取代。

## 文档约定

- 一个文件一个主题；文件名即主题。
- 长内容不塞 README；README 只回答"30 秒能得到什么"。
- 文档里的路径必须真实存在。