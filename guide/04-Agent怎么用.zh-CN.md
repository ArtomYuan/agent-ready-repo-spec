# 04 · Agent 怎么用
**[English](04-Agent怎么用.md)** · 简体中文

> 这一章讲**把仓库交给 agent 时的操作方式**，不讲话术技巧。
> 主要依据 Anthropic 官方的 [Best practices](https://code.claude.com/docs/en/best-practices)、
> [Memory](https://code.claude.com/docs/en/memory)、[Skills](https://code.claude.com/docs/en/skills)、
> [Subagents](https://code.claude.com/docs/en/sub-agents)，以及 `cli/cli`、`python/cpython` 等仓库里
> 真实在用的 `AGENTS.md` 写法。

---

## 0. 地基：先分清两类指令

官方文档把每一条给 agent 的指令分成两种，这个区分决定了后面一切做法：

| | 非确定性（模型自己决定） | 确定性（harness 强制执行） |
|---|---|---|
| 载体 | 你的 prompt、`AGENTS.md`/`CLAUDE.md`、skill | hook、`deny` 规则、managed settings |
| 谁执行 | 模型 | Claude Code 本体 |
| 保证 | **通常**遵守，没有保证 | **每一次**都执行，不管模型怎么想 |

官方原话很值得抄下来：

> Almost every guideline has exceptions... With the actual code in front of it, Claude is usually better placed to make that call than a rule you wrote in advance.
> （绝大多数规则都有例外；看到真实代码时，模型通常比你事先写下的规则更会判断。）

**所以默认应该是"让模型判断"，只把"绝不能有例外"的那几条升级成确定性机制。**
这条和"指导性文档不替人做决定"是同一个道理——只不过对象从人换成了 agent。

---

## 1. 给上下文：短、分层、按需

### 1.1 根文件要短

官方建议在 `CLAUDE.md`/`AGENTS.md` 里只写**模型看不到、又每次都要用**的东西：

- 跑测试/构建/lint 的那几条命令
- 目录地图（哪个目录做什么，哪里有雷）
- 硬约定（提交格式、不许动的目录）
- 已知的坑

**不要**写：架构长文、代码风格百科、能从代码读出来的东西。

### 1.2 按目录分层，而不是把根文件写长

官方在 [large codebases 指南](https://code.claude.com/docs/en/large-codebases) 给的做法：

- 根放共享约定；每个包/子系统再放一份（`packages/api/CLAUDE.md`）；
- 根在启动时加载，**子目录的只在你读到那里时才加载**；
- 不想加载的包用 `claudeMdExcludes` 排除；
- 也可以改成 `path-scoped rules`（`.claude/rules/*.md` + `paths:`）。

### 1.3 多步流程放 skill，不占根文件

官方明确"把团队流程放进 skills"：流程只在被调用时加载，不占日常上下文。
判断标准：**每次都要知道 → 根文件；做某件事时才需要 → skill。**

### 1.4 一个被真实使用的写法

`cli/cli` 的做法值得抄：agent 定义里先声明优先级，再叠加仓库自己的覆盖层——

```markdown
## Repository Instructions Overlay
If `.github/aw/instructions.md` exists, load it with:
@.github/aw/instructions.md

Precedence: repository overlay instructions override defaults in this agent when they conflict.
```

**"默认 + 仓库覆盖层 + 明写优先级"**，比两边各写一份、靠模型猜要可靠得多。

---

## 2. 给检查：让它能自己判断"做完了"

官方这句话是整章的题眼：

> Claude stops when the work looks done. If it has nothing to run that tells it whether the work actually *is* done, "looks done" is all it has to go on.
> （模型在"看起来做完了"时停下。如果没有能跑出 pass/fail 的东西，"看起来"就是它唯一的依据。）

四种收紧方式，从松到紧：

| 级别 | 做法 | 什么时候够用 |
|---|---|---|
| 1 | prompt 里说"跑测试，直到全过" | 一次性任务 |
| 2 | 设成目标（`/goal all tests pass and lint is clean`），每轮由另一个模型核对 | 长任务、后台跑 |
| 3 | 在 `AGENTS.md` 里写明"提交前必跑 X"，并在 PR 模板里要求贴输出 | 日常协作 |
| 4 | CI required check / `Stop` hook 拦住"没跑就结束" | 一定要保证 |

**投入产出比最高的一句话**：如果你的仓库已经有测试/lint/类型检查，那么 `AGENTS.md` 里最值钱的一行就是**跑它的那条命令**。

---

## 3. 给边界：哪些必须确定性

官方给的三个例子可以直接照搬：

| 规则 | 写在 `AGENTS.md` 里 | 升级为确定性 |
|---|---|---|
| 不要读 `.env` | 模型通常遵守 | `permissions.deny: ["Read(./.env)"]` |
| 改完必须格式化 | 经常忘 | `PostToolUse` hook 直接跑 formatter |
| 不要动 `migrations/` | 偶尔会绕 | `Edit(./migrations/**)` deny，或 hook 里 `exit 2` |

要点：

- **hook 里不要用 `prompt`/`agent` 类型做强制的判断**——那仍然是模型判断，不是确定性。要强制就用 `command`/`http`。
- 如果"hook 自己崩了"也必须拦住，加 `onFailure: "block"`。
- 确定性手段是**稀缺资源**：只给"绝不能有例外"的规则用，否则会把仓库变成不可维护的规则迷宫。

---

## 4. 会话操作：什么时候用哪种模式

| 场景 | 做法 | 什么时候**不**该用 | 成本量级 |
|---|---|---|---|
| 改动跨多个文件、方向不明 | 先 plan mode 出方案再执行（官方 permission modes） | 方案已经明确时——多一轮确认只是延迟 | 无额外调用，多一次交互 |
| 一次改很多、互不相干的文件 | 派 subagent，各自独立上下文（[Subagents](https://code.claude.com/docs/en/sub-agents)） | 任务之间有强依赖、需要共享中间结论时 | 每个 subagent 重新读一遍相关文件；3 个 ≈ 3 份上下文 |
| 多个任务并行、会互相踩文件 | 每个任务一个 worktree（[Worktrees](https://code.claude.com/docs/en/worktrees)） | 只改同一个文件时 | 磁盘与依赖安装成本，首次准备较慢 |
| 需要大量搜索/读文件才能定位 | 交给 subagent 去搜，主上下文只要结论 | 读一两个文件就能定位时 | 一次独立读取，只回传结论 |
| 长任务、可以无人值守 | 设目标 + 明确检查 + 预算上限（`--max-turns` / `--max-budget-usd`） | 没有可运行的检查时——无人值守只会放大错误 | 按 token 与轮次计费 |

### subagent 的账要算对

官方列的是它**在哪些情况下划算**：

- 把独立的工作并行，整体更早完成；
- 把长输出（一次完整测试、一次大范围搜索）挡在主对话之外——否则它会跟着整个会话一直占着上下文；
- 拿到一个**没见过代码是怎么写的**评审者；
- 给任务**更少的工具**（例如只读评审）。

代价的机制在这里：**subagent 有独立的上下文窗口，它要重新读一遍相关文件才能干活。**
所以在文件大、依赖多的仓库里，"派一个 subagent 去查"的总成本可能高于在主上下文里查一次。
**它不是免费的并行，是用上下文换隔离。**

同源的一个效果问题：**上下文越满，判断质量越差**。
所以"根文件短、流程进 skill、搜索进 subagent"不是洁癖，是在保质量。

官方还说明：宽泛的代码库搜索会自动交给内置的 Explore agent，侧任务在 fork 模式下默认分叉并在后台跑——
也就是说**这些切换很多时候不是你决定的**，你至少要知道它的账怎么算。

---

## 5. 反例

| 反例 | 问题 | 改法 |
|---|---|---|
| 把所有规则都写成 hook | 不可维护，且模型失去判断空间 | 只升级"绝不能有例外"的 |
| `AGENTS.md` 写 500 行 | 每次会话都付费，遵守率还下降 | 超过 200 行就分层或改路由 |
| 没有可运行的检查，只靠人看 | 人变成测试套件 | 给一条能跑出 pass/fail 的命令 |
| 让 agent"注意代码风格" | 无法执行 | 给 formatter + lint 命令 |
| 一个会话里连做五件不相关的事 | 上下文污染、互相踩 | 拆 subagent / worktree |
| 用 prompt hook 做安全拦截 | 仍是模型判断 | 换 `command` hook + `exit 2` |

---

## 6. 判据：这套用法是否到位

**硬性（这四条不成立，说明做法没到位）**

- [ ] 仓库里有**一条命令**能告诉 agent"你做对了没有"？
- [ ] 那条命令，最近一次实际跑通是什么时候？
- [ ] 有没有哪条"绝不能有例外"的规则，却还只写在文档里？
- [ ] 子目录的约定是分层加载的，还是全塞在根文件里？

**视情况（没做也可以，但要能说出理由）**

- [ ] 反过来看：有没有把"有例外的规则"硬写成了 hook？
- [ ] 多步流程在 skill 里，还是在根文件里？
- [ ] 需要隔离上下文时你派了 subagent，还是把搜索结果全塞进了主对话？

> 这些不是评分项。勾满不等于用法到位，勾不满也不等于有问题——**理由比勾重要。**

---

## 7. 依据

| 论断 | 来源 |
|---|---|
| 确定性 vs 非确定性指令；"多数时候应让模型判断" | [Best practices · Deterministic and non-deterministic instructions](https://code.claude.com/docs/en/best-practices) |
| "给一个能跑出 pass/fail 的检查"；四级收紧 | 同上 · Give Claude a check to run |
| 不可例外的规则用 hook / deny / managed settings；`onFailure: block` | 同上 · Enforce the rules that can't have exceptions |
| 根文件短、按目录分层、`claudeMdExcludes`、per-directory skills | [Set up Claude Code in a monorepo](https://code.claude.com/docs/en/large-codebases) |
| 加载顺序与作用域 | [How Claude remembers your project](https://code.claude.com/docs/en/memory) |
| 覆盖层 + 优先级声明的真实写法 | `cli/cli` 的 `.github/agents/agentic-workflows.md`（实测） |

---

## 附：本章对应的自查项

只做导航——判据本身在 [spec/checklist.md](../spec/checklist.md)。

| 条目 | 本章解释它什么 |
|---|---|
| `R005` | "给检查"——没有可运行的检查，就没有拒绝 agent 改动的依据 |
| `R024` `R026` | 权限基线：共享配置进版本库、`deny` 非空 |
| `R030` `R031` `R032` | 什么该进 `AGENTS.md`，什么必须分层放别处 |
| `R034` `R040` | 真能拦住的 hook：脚本存在，且违规分支 `exit 2` |
| `R035` | 能被自动命中的 skill（`name` + `description`） |

证据：[docs/evidence/2026-11-17-claude-code-docs.md](../docs/evidence/2026-11-17-claude-code-docs.md)。
