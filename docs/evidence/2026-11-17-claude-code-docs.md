# 证据 · Claude Code 官方文档摘录

- **采集时间**：2026-11-17
- **方法**：抓取 `code.claude.com/docs/en/*.md`（文档站提供 markdown 版本）与 `docs.github.com`
- **用途**：给 `guide/03`（attribution / includeGitInstructions）、`guide/06`（memory 的覆盖边界）提供可核对原文

## 1. 提交归属与 git 指令（`settings-reference`）

> `attribution`：Customize the attribution Claude Code adds to git commits and pull requests. Commits get a **git trailer** such as `Co-Authored-By` by default

> `attribution.commit` — **Default**: unset, so Claude Code adds `Co-Authored-By: <name> <noreply@anthropic.com>`.
> The name is the model in use when the commit is made, such as `Claude Sonnet 5`. When a subagent makes the commit, the trailer names the subagent's model.
> Set it to an empty string to hide commit attribution.

> `includeGitInstructions` — Claude Code gives Claude two git-related pieces of context: its **built-in instructions for how to write commits and pull requests, in the Bash tool's description**, and a git status snapshot… Set this key to `false` to leave both out. **Default**: `true`
> `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` takes precedence over this key for one session.

> `includeCoAuthoredBy` — **Deprecated**; use `attribution` to hide or change commit and PR attribution.

## 2. 记忆的覆盖边界（`memory`）

> `CLAUDE.md` files… Claude treats them as context, not enforced configuration.

> Auto memory… Each project gets its own memory directory at `~/.claude/projects/<project>/memory/`…
> The first 200 lines of `MEMORY.md`, or the first 25KB, whichever comes first, are loaded at the start of every conversation.
> **Auto memory is machine-local.** All worktrees and subdirectories within the same git repository share one auto memory directory. **Files are not shared across machines or cloud environments.**

> Subagents can also maintain their own auto memory… the `memory` field in the subagent definition picks where that memory directory lives: `user` / `project` / `local`.

## 3. 确定性 vs 非确定性指令（`best-practices`）

> 1. **Non-deterministic**: you write the instruction, and Claude (the model) reads it… there's no *guarantee* that it'll follow your instructions.
> 2. **Deterministic**: you configure the instruction, and Claude Code (the harness) *has to* execute this… Claude Code applies this every time, no matter what the model decided to do.

> Almost every guideline has exceptions… With the actual code in front of it, Claude is usually better placed to make that call than a rule you wrote in advance.

> **Who has the last word** — Branch protection, a person who approves the merge.

## 4. GitHub 的社区健康文件识别

**`community/profile` API 实测**（2026-11-17）：

| 仓库 | GitHub 认到的 contributing 路径 |
|---|---|
| github/docs | `.github/CONTRIBUTING.md` |
| cli/cli | `.github/CONTRIBUTING.md` |
| actions/checkout | `CONTRIBUTING.md` |
| psf/requests | `.github/CONTRIBUTING.md` |
| pallets/flask | `docs/contributing.rst`（小写 + `.rst` 也认） |
| anthropics/claude-code | `null`（health 50%） |

→ 目录只有三个（根 / `.github/` / `docs/`），文件名不区分大小写、`.rst` 也认，**`contributing/` 目录本身不算**。

**README 位置**（[About the repository README file](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)）：
取 `.github/` > 根 > `docs/` 的第一个；超过 500 KiB 截断。

**组织级默认**（[Creating a default community health file](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file)）：
名为 `.github` 的**公开**仓库，承载 `CONTRIBUTING` / `SECURITY` / `CODE_OF_CONDUCT` / `ISSUE_TEMPLATE`，单仓库同名文件覆盖。
