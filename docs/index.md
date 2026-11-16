# 文档地图

本仓库有三类读者，入口分开。

## 我是人，想用这套规范

| 我想 | 去哪 |
|---|---|
| 30 秒跑一次体检 | [README.md](../README.md) |
| 知道 L0–L3 到底要求什么 | [spec/RULES.md](RULES.md) |
| 接进自己的 CI | [guides/use-in-ci.md](guides/use-in-ci.md) |
| 贡献一条规则 | [CONTRIBUTING.md](../CONTRIBUTING.md) |

## 我是 agent，要替人管一个库

先读 [AGENTS.md](../AGENTS.md)（每次会话的事实源），再读 **[spec/agent-playbook.md](../spec/agent-playbook.md)**（操作手册）。
动手时用 skill：`audit-repo`（体检 + 分诊）、`bootstrap-repo`（建基线）。

## 我在看设计

| 我想 | 去哪 |
|---|---|
| 为什么规则是 JSON、文档是生成的 | [adr/0001-rules-as-single-source.md](adr/0001-rules-as-single-source.md) |
| 检查器的边界与不做什么 | [adr/0002-checker-is-read-only.md](adr/0002-checker-is-read-only.md) |
| 引擎结构 | [architecture/checker.md](architecture/checker.md) |
| **证据与实测数据** | [evidence/](evidence/)（按采集日期命名：仓库采样、本仓库自审、官方文档摘录、分支保护实测） |

## 文档约定

- 一个文件一个主题；文件名即主题。
- 长内容不塞 README；README 只放“30 秒能得到什么”。
- 文档里的路径必须真实存在（CI 会查 `AGENTS.md`）。
