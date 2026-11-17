# 采样：高星仓库的 agent 指令文件到底怎么写

- 采集日期：2026-11-18
- 采集方式：`gh api repos/{owner}/{repo}/contents/{path}`，取原文后统计行数与二级标题
- 用途：为 `examples/` 提供依据——**示例要照着真实仓库写，不照着我的偏好写**

## 一、有没有这个文件

| 仓库 | 文件 | 体积 |
|---|---|---|
| cli/cli | `AGENTS.md` | 5.7 KB / 105 行 |
| python/cpython | `AGENTS.md` | 1.0 KB / 30 行 |
| microsoft/vscode | `AGENTS.md`（+ `.github/copilot-instructions.md` 14.5 KB） | 0.5 KB / 8 行 |
| kubernetes/kubernetes | `AGENTS.md` | 1.8 KB / 40 行 |
| openai/openai-python | `AGENTS.md` | 4.4 KB / 60 行 |
| supabase/supabase | `AGENTS.md`（+ `copilot-instructions.md` 6.5 KB） | 7 KB / 78 行 |
| rust-lang/rust | `AGENTS.md` | 13.5 KB / 266 行 |
| vercel/next.js | `AGENTS.md` | 33.6 KB / — |
| modelcontextprotocol/servers | `AGENTS.md` | 50 KB / — |
| anthropics/claude-code | `CLAUDE.md` | 2.2 KB / 41 行 |
| denoland/deno | `CLAUDE.md` 11.6 KB + `copilot-instructions.md` 12.3 KB | — |
| github/docs、actions/checkout、sindresorhus/got、shadcn-ui/ui | **都没有** | — |

结论：**头部仓库多数已有，但不是普遍要求**；`github/docs`、`actions/checkout` 这类以内容/单动作为主的仓库仍然没有。

## 二、结构上观察到四种形态

### 1. 路由型（最小）—— microsoft/vscode，全文 8 行

```markdown
# VS Code Agents Instructions
This file provides instructions for AI coding agents working with the VS Code codebase.
For detailed project overview, architecture, coding guidelines, and validation steps,
see the Copilot Instructions (.github/copilot-instructions.md).
Prefer `CancellationToken`/`CancellationTokenSource` internally and adapt `AbortSignal`
only at native or third-party API boundaries; see the cancellation guidance.
```

**只做两件事**：指向真正的细则；把"最容易做错的那一条"直接写在门口。

### 2. 沟通 + 约束 + 命令 + 风格 —— kubernetes/kubernetes，40 行

一级标题下五节：`Communication Preferences` / `Constraints` / `Contributor Guidelines` / `Commands` / `Style`。

值得抄的三点：

- **写了沟通偏好**："Dry, concise, low-key humor. No flattery, no forced memes. Skip preambles and postambles."（语气也是可配置项，这一点我们的骨架里没有）
- **约束全是"不要手改"**：`zz_generated.*` 只读、`go.mod` 是生成物、staging 才是源头——每条都带**替代做法**
- **PR 层面要求声明 AI 使用**，并要求人类作者承担全部责任

### 3. 所有权 + 安全 + 验证 —— openai/openai-python，60 行

七节：`Generated SDK` / `Security requirements for coding agents` / `Python version policy` /
`Changing the minimum Python version` / `Automation map` / `Validation` / `Large-payload compatibility`。

值得抄的两点：

- **`Automation map`**：逐个 workflow 说明"它管什么"，例：`ci.yml` = PR/branch 的 lint、build、metadata、
  最小/当前版本测试；`python-version-review.yml` = 每月复核，**以只读权限、无网络、不改仓库的方式运行**。
- **`Validation`**：给出可以直接粘贴执行的命令行，并在正文写清"确定性的策略检查只能证明一致，不能证明该不该这么选"。

### 4. 大全型 —— vercel/next.js 33.6 KB、modelcontextprotocol/servers 50 KB

根文件承载全部约定，没有分层。**只有单团队、约定集中、且能持续维护时才成立。**

## 三、和本规范冲突的两处（重要）

| 仓库 | 做法 | 与本规范的差异 |
|---|---|---|
| kubernetes/kubernetes | "**Do not add `Co-authored-by:`** in commit messages"；也不许在 commit 里写 `@mentions` / `fixes #...` | 本规范 `R029` 建议**保留** agent 归属（trailer 是审计线索）。**两种都成立**：k8s 把归属移到 PR 描述与 AI 使用声明里，避免提交历史被机器署名污染 |
| kubernetes/kubernetes | "squash fixes back into the commits they are fixing；不要推一连串 fixup 提交" | 与本规范 `R051`（线性历史）方向一致，但更严格 |

> 结论：把"归属"写成 `should` 是对的——它确实是**取决于文化**的选择，不是 `must`。

## 四、对本库的影响

1. `examples/` 应当给**两份对照样本**（而不是一份"标准答案"）：
   - 小仓库：路由型（8 行 vscode 那种）
   - 中型仓库：约束 + 命令 + 验证（kubernetes / openai 那种）
2. 骨架里可以补一节 **`## Communication`（沟通偏好）**——k8s 证明语气也是真实需求，且我们的 `prompt-locale` 只覆盖了语言。
3. 骨架里可以补一节 **`## Automation map`**——openai 的做法解决了"仓库里一堆 workflow，没人知道哪个管什么"。
4. `guide/02` 的"路由型"目前只有体积数字，可以把 vscode 的 8 行原文作为对照。

## 复现与局限

- **引用方式**：`https://github.com/{owner}/{repo}/blob/{commit}/AGENTS.md`。本报告记的是 2026-11-18 默认分支的快照
  （行数 / 体积见第一节），上游随时会改；复现时按**行数与二级标题数**近似匹配，而不是逐字比对。
- **样本性质**：非随机、非分层的便利样本，且偏向 GitHub / Anthropic 生态（12 个里 4 个是这两家的仓库）。
  它支撑"存在哪些形态"，**不支撑**"多数仓库如此"这类比例结论——正文凡出现比例，都必须写明样本量。
- **原始文本不入库**：抓取件含第三方仓库全文，长期引用请用上面的固定 commit 链接，不复制进本库。
