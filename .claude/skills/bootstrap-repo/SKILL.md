---
name: bootstrap-repo
description: 用 templates/ 给一个新仓库或存量仓库补齐规范基线（L0→L2），生成 AGENTS.md、settings.json、CODEOWNERS、PR 模板、ADR。用户说“给这个库建基线/初始化规范/接入这套规范”时使用。
allowed-tools: Read, Write, Edit, Glob, Bash(git *), Bash(pwsh *)
---

# 给仓库建规范基线

## 前置：先体检，不要盲建

```bash
pwsh ./checker/spec-check.ps1 -Target <path> -Level 2 -Format json
```

已有文件一律**保留并合并**，不要覆盖。目标仓库可能已经有一份更好的 AGENTS.md。

## 建文件的顺序（按依赖排，不要乱）

| 顺序 | 文件 | 来源模板 | 关键点 |
|---|---|---|---|
| 1 | `.gitignore` | 手写 | 先加 `.claude/settings.local.json`、`CLAUDE.local.md`、`.env*` |
| 2 | `AGENTS.md` | `templates/AGENTS.md.tmpl` | 只写命令 + 目录地图 + 硬约定 + 禁区；**先短**，≤200 行 |
| 3 | `README.md` | 手写 | 一句话定位 + 30 秒跑起来的命令 + 入口链接 |
| 4 | `.claude/settings.json` | `templates/settings.json.tmpl` | 只放声明式 deny；不要一上来写 hook 脚本 |
| 5 | `.github/CODEOWNERS` | `templates/CODEOWNERS.tmpl` | owner 必须是人类账号；覆盖 `.claude/`、`.github/workflows/`、`AGENTS.md` |
| 6 | `.github/PULL_REQUEST_TEMPLATE.md` | `templates/PULL_REQUEST_TEMPLATE.md.tmpl` | 必须有自检清单（`- [ ]`） |
| 7 | `CHANGELOG.md` | 手写 | Keep a Changelog，从 `## [Unreleased]` 起 |
| 8 | `CONTRIBUTING.md` / `SECURITY.md` | 手写 | 分支模型 + 评审 SLA；私密上报入口 |
| 9 | `docs/index.md` + `docs/adr/0001-<slug>.md` | `templates/adr.md.tmpl` | ADR 第一条就写“为什么现在做这件事” |
| 10 | `CLAUDE.md` | 手写 | **第一行 `@AGENTS.md`**，其余不超过 40 行 |

## 收尾：必须做的三件事

1. 重跑体检，确认 `achievedLevel` 前进到目标级别。
2. 打印“还差什么”，把 `may` 级项留成 issue，不要当场全做。
3. 告诉人：**分支保护要手动开**（禁止直推 main、Require review from Code Owners、关掉 force push）。
   这一步检查器看不到，但没有它前面的文件都是装饰。

## 禁区

- 不覆盖目标仓库已有的同名文件（先 diff，再合并）。
- 不写占位符就交付（`{{OWNER}}`、`@example-org` 必须替换或明确标注 TODO）。
- 不替用户决定协议类型、团队名、SLA 数字——问，不要猜。
