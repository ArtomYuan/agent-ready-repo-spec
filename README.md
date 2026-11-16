# agent-ready-repo-spec

**一个仓库要有哪些文档、什么目录，agent 参与管理时该怎么治理——写成规则，能用一条命令给任意仓库体检。**

不是又一篇 best-practice 文章：规则是**机器可读的 JSON**，检查器会把结论落成 `PASS / FAIL + 修复建议 + 达成等级`，人和 agent 都能直接消费。

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

输出长这样：

```
spec-check 1.0.0  target: D:\code\my-repo  (检查到 L3)

L0 — 能被人和 agent 读懂并跑起来
  [ok]   R001  存在 README
  [FAIL] R002  根目录存在 AGENTS.md  (must)
         > 缺失: AGENTS.md
         fix: 在根目录建 AGENTS.md，只写命令、目录地图、硬约定、禁区、已知的坑
...
must 5/6   should 6/18   may 3/7   score 27/100   达成 未达 L0
未通过（fail-on: must）
```

## 三种用法

| 你是 | 你需要的 | 入口 |
|---|---|---|
| 人，想给自己仓库打分 | 跑一条命令，看 FAIL 和修复建议 | 上面那段 |
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
