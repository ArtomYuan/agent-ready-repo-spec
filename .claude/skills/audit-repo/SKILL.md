---
name: audit-repo
description: 按 agent-ready-repo-spec 给任意仓库做规范体检、分诊 FAIL、给出修复顺序。用户说“体检/审计/看看这个库合不合规/audit this repo”时使用。
allowed-tools: Read, Grep, Glob, Bash(git *), Bash(ls *), Bash(pwsh *), Bash(powershell *)
---

# 给一个仓库做规范体检

## 0. 先确定三件事

1. **目标仓库路径**（默认当前目录）。
2. **目标等级**：默认 L3；如果对方只是想知道“能不能用”，跑 `-Level 1` 更快。
3. **是不是要改它**：只读体检 → 到这里为止；要修 → 走第 4 步，且**必须逐项让人确认**。

## 1. 跑检查器

```bash
pwsh ./checker/spec-check.ps1 -Target <path> -Level 3 -Format json
```

Windows 执行策略受限时换：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\checker\spec-check.ps1 -Target <path> -Format json
```

**不要**用 `-Format text` 做批量判断，JSON 里的 `results[].ok / severity / fix` 才是可消费的。

## 2. 读结果（关键）

按这个顺序读，不要按规则 ID 顺序：

1. `summary.must.fail` > 0 → 这是硬伤，先修完再谈别的。
2. `achievedLevel` → 真实的成熟度。**报“L3 有 12 条 FAIL”是噪音，报“实际达成 L1，离 L2 差 3 项”才有用。**
3. 只列 `severity in (must, should)` 的 FAIL，`may` 单独归到“可选加分”。

## 3. 输出给人看的三段式

```
结论：达成 L1。要上 L2 差 3 项，其中 1 项是硬伤。
硬伤：R025 settings.local.json 已被提交（先撤销提交，再进 .gitignore）
阻断 L2：R020 缺 SECURITY.md、R023 无 ADR、R026 permissions.deny 为空
建议顺序：先修硬伤 → 补 3 个文件 → 再跑一次确认达成 L2
```

禁止输出“共 12 个问题”这种没有优先级的清单。

## 4. 修复（要人确认后才动）

- 一次只修**一个级别**：L0 全绿再动 L1。
- 新建文件用 `templates/` 里的模板，把 `{{PLACEHOLDER}}` 换成真实值，**不要留占位符**。
- 修完立刻重跑同一条命令，对比 `achievedLevel` 是否前进。
- 不要为了让检查通过而删规则、放宽 severity、或加 `.specignore` 之类的逃生门。

## 5. 边界

- 检查器只读。想让它“自动修”，是另一个决定（见 `docs/adr/`），不要顺手实现。
- 目标仓库如果是第三方/公开仓库，只做只读体检，**不要提交任何改动**。
- 报告里不要贴目标仓库的密钥、内网地址、真实用户数据。
