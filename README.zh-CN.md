# agent-ready-repo-spec

**简体中文** · [English](README.md)

**一个仓库要有哪些文档、什么目录，agent 参与管理时该怎么治理——写成规则，能用一条命令给任意仓库体检。**

不是又一篇 best-practice 文章：规则是**机器可读的 JSON**，检查器据此输出**自查清单**（已有 / 建议补 / 跳过）+ 每条一句修复建议；加 `-Assess` 才给评分与达成等级。人和 agent 都能直接消费。

> **能力边界**：检查器保证**下限**——不缺件、不断链、不出现双事实源；**不保证上限**——文档写得对不对、架构好不好，它判不了。
> 全部 `[ok]` 只说明"该有的都有"，不说明"这是个好仓库"。

```
L0 — 能被人和 agent 读懂并跑起来
L1 — 能接受第三方贡献且不被打断
L2 — 能对外、能生产、决策可追溯
L3 — agent 提交占多数时的治理与防腐
```

---

## 30 秒上手

```bash
git clone <your-fork-url> agent-ready-repo-spec
cd agent-ready-repo-spec
pwsh ./checker/spec-check.ps1 -Target /path/to/the/repo/you/want/to/audit
```

Windows 上执行策略是 `Restricted` 时：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\checker\spec-check.ps1 -Target D:\code\my-repo
```

输出长这样（**示例**：对象是一个缺 3 项的普通仓库，不是本库本身）：

```
spec-check 1.3.0  target: D:\code\my-repo  (检查到 L3)
共 36 项：适用 34，跳过 2

L0 — 能被人和 agent 读懂并跑起来
  [ok]   R001  存在 README
  [todo] R002  根目录存在 AGENTS.md  (must)
         > 缺失: AGENTS.md
         fix: 在根目录建 AGENTS.md，只写命令、目录地图、硬约定、禁区、已知的坑
...
已有 31 · 建议补 3 · 跳过 2
这是自查清单，不是评级；要看得分与达成等级请加 -Assess。
```

## 先读指导，再用自查

这个库的**正文是指导**：一个 GitHub 仓库该有什么文档、什么结构、该怎么写、agent 该怎么用与怎么管它。
`rules/`、`checker/`、`templates/` 只是配套的自查工具与样例——不替你做决定，也不替你执行。

| 你想知道 | 去哪 |
|---|---|
| **接入时该选哪一档、决定记在哪** | [guide/00-接入决策.md](guide/00-接入决策.md) · 模板 [templates/adoption.md.tmpl](templates/adoption.md.tmpl) |
| 某个文件**到底该怎么写**（README / AGENTS.md / CODEOWNERS / ADR / PR 模板 / CHANGELOG） | [guide/03-文档该怎么写.md](guide/03-文档该怎么写.md) |
| 指导正文的全貌与其余章节 | [guide/README.md](guide/README.md) |

## 三种用法

| 你是 | 你需要的 | 入口 |
|---|---|---|
| 人，想写对文档 | 读写法 + 对照反例 | [guide/03-文档该怎么写.md](guide/03-文档该怎么写.md) |
| 人，想自查有没有遗漏 | 跑一条命令，看 FAIL 和修复建议 | 上面那段 |
| agent，想学会怎么管一个库 | 读操作手册 → 按 skill 执行 | [AGENTS.md](AGENTS.md) · [spec/agent-playbook.md](spec/agent-playbook.md) |
| CI，想常驻门禁 | 只跑 `must`，失败即红 | [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) |

## 规则分级

| 级别 | 判据 | 典型规则 |
|---|---|---|
| **L0** | 人和 agent 都能在 30 秒内接手 | `README` `AGENTS.md` `.gitignore` `LICENSE` `CI` |
| **L1** | 外部贡献者不会问“我该怎么提” | `CONTRIBUTING` `CODEOWNERS` `PR/Issue 模板` `CHANGELOG` |
| **L2** | 有事能查、有决策能追溯 | `SECURITY` `docs/`（含 `adr/`）`.claude/settings.json` |
| **L3** | agent 的改动可拒绝、可回滚、不腐烂 | `AGENTS.md` 体积/结构、`hooks` 引用有效、`CLAUDE.md` 薄层、引用不失效 |

完整规则表（由 `rules/rules.json` 生成，勿手改）：[spec/RULES.md](spec/RULES.md)

## 一条规则长什么样

```json
{
  "id": "R033",
  "level": 3,
  "severity": "should",
  "title": "CLAUDE.md 是薄适配层",
  "check": { "kind": "file-limit", "file": "CLAUDE.md", "regex": "@AGENTS\\.md", "max": 40 },
  "rationale": "CLAUDE.md 与 AGENTS.md 各写一份会形成双事实源，agent 随机选一个生效。",
  "fix": "CLAUDE.md 第一行写 @AGENTS.md，只保留 Claude 专属的少量补充。"
}
```

`severity` 三档：`must`（硬伤）/ `should`（该有）/ `may`（加分）。退出码只看你指定的阈值。

## 新增或修改规则

```bash
# 1. 改 rules/rules.json
# 2. 重新生成规则表
pwsh ./checker/gen-rules-doc.ps1
# 3. 跑自测（会用临时 fixture 验证引擎行为）
pwsh ./tests/selftest.ps1
# 4. 用自己体检自己
pwsh ./checker/spec-check.ps1 -Target .
```

规则变更必须同步 `CHANGELOG.md`；改语义要升 `specVersion`。

## 目录

```
rules/rules.json        唯一事实源（机器可读）
spec/RULES.md           由 rules.json 生成的人读版本
spec/agent-playbook.md  agent 如何用这套规范管理仓库
checker/spec-check.ps1  检查器（无第三方依赖）
checker/gen-rules-doc.ps1  生成 RULES.md
templates/              可复制到目标仓库的模板
docs/                   设计说明、ADR、CI 接入
tests/selftest.ps1      fixture 自测
.claude/                本仓库自己的权限、规则、skill
```

## 为什么是 PowerShell

规则是 JSON，引擎是薄薄一层。选 PowerShell 因为它**在三大平台的 GitHub Runner 上都预装**，不引入 Node/Python 运行时依赖；想换语言重写，照着 `rules.json` 的 16 种 `check.kind` 实现即可。

## 许可

MIT，见 [LICENSE](LICENSE)。
