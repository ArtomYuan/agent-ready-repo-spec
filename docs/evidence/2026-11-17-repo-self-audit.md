# 证据 · 本仓库自身的可交接性审计

- **采集时间**：2026-11-17
- **方法**：GitHub REST API（`commits` / `pulls?state=all` / `issues?state=open`）
- **目的**：回答"如果换一个会话接手，只看 PR 和 commit 能知道什么"

## 1. 提交信息

```
e0bb535  docs(guide): 修正本仓库采用记录里的未采用项描述 (#6)
68ddcf7  docs(guide): 新增 00-接入决策与采用记录模板 (#5)
7eb4aa3  docs(adr): 记录保护实测值与直推被拒的验证 (#4)
9b06a06  docs(process): 变更改为走 PR 并锁定 main (#3)
fde2af1  docs(guide): 04/05 定稿 —— bypass 写硬、引用原文、会话成本、判据分档，并记录 admin 强制例外
eb3f9cb  docs(guide): 01 该有什么文档、02 目录结构，依据 GitHub/Claude Code 官方规则与十个仓库实测
```

→ **只有标题（+ squash 的 `#N`），没有正文**。能看出"做了什么类别的事"，看不出"下一步"。

## 2. PR 描述长度

| PR | 标题 | 正文字符数 |
|---|---|---|
| #6 | docs(guide): 修正采用记录里的未采用项描述 | 163 |
| #5 | docs(guide): 新增 00-接入决策与采用记录模板 | 163 |
| #4 | docs(adr): 记录保护实测值与直推被拒的验证 | 159 |
| #3 | docs(process): 变更改为走 PR 并锁定 main | 165 |
| #2 | chore(ci): bump the actions group（Dependabot） | 32 079 |
| #1 | chore(ci): bump the actions group with 2 updates | 24 145 |

→ #3–#6 的正文是**同一个模板套话**（`## 改了什么` + `## 怎么验证的` + "由 publish-pr.ps1 自动创建"），信息量≈0。

## 3. 待办载体

```
打开中的 issue（非 PR）：0
打开中的 PR：1（#2 Dependabot，自动生成）
```

→ **没有任何"下一步/待办"的载体**。

## 4. 结论

| 问题 | 能否回答 |
|---|---|
| 做了什么 | ✅（标题 + diff） |
| 为什么这样做 | 部分（4 条 ADR 覆盖了门禁/规则源等大决定） |
| **下一步做什么** | ❌ |
| **哪里还需要调整** | ❌ |

这就是 `guide/06` 里"未采用方式 C"的实测依据。
