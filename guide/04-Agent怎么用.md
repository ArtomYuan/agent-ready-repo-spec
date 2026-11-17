# 04 · Using an agent

**English** · [简体中文](04-Agent怎么用.zh-CN.md)

> This chapter is about **how to operate** when handing a repository to an agent — not about prompt tricks.
> Sources: Anthropic's [Best practices](https://code.claude.com/docs/en/best-practices),
> [Memory](https://code.claude.com/docs/en/memory), [Skills](https://code.claude.com/docs/en/skills),
> [Subagents](https://code.claude.com/docs/en/sub-agents), plus the `AGENTS.md` files actually used in
> `cli/cli` and `python/cpython`.

---

## 0. The foundation: two kinds of instruction

The official docs split every instruction you give an agent into two kinds, and that split decides everything below:

| | Non-deterministic (the model decides) | Deterministic (the harness enforces) |
|---|---|---|
| Carrier | your prompt, `AGENTS.md`/`CLAUDE.md`, skills | hooks, `deny` rules, managed settings |
| Who executes | the model | Claude Code itself |
| Guarantee | it **usually** complies — no guarantee | **always**, regardless of what the model decided |

Worth quoting in full:

> Almost every guideline has exceptions... With the actual code in front of it, Claude is usually better placed to make
> that call than a rule you wrote in advance.

**So the default should be "let the model judge", and only the "no exceptions" rules get promoted to deterministic
mechanisms.** This is the same reasoning as "guidance documentation does not make decisions for people" — only the
subject changes from humans to agents.

---

## 1. Give it context: short, layered, on demand

### 1.1 Keep the root file short

Only what the model **cannot see and needs every time**:

- the commands to build / test / lint
- a directory map (what each area is, where the traps are)
- hard rules (commit format, untouchable directories)
- known pitfalls

**Do not** put in: long architecture essays, a style encyclopaedia, anything derivable from the code.

### 1.2 Layer by directory instead of growing the root file

Per Claude Code's [large codebases guide](https://code.claude.com/docs/en/large-codebases):

- shared conventions at the root; one more per package/subsystem (`packages/api/CLAUDE.md`);
- the root loads at startup, **subdirectory files load only when work reaches them**;
- exclude packages with `claudeMdExcludes`;
- or replace a pile of files with `path-scoped rules` (`.claude/rules/*.md` + `paths:`).

### 1.3 Put multi-step procedures in skills

Official advice: move team procedures into skills — they load only when invoked and don't consume the daily budget.
The test: **needed every session → root file; needed only to do one thing → skill.**

### 1.4 A pattern real repositories use

`cli/cli` declares precedence and layers a repository overlay on top:

```markdown
## Repository Instructions Overlay
If `.github/aw/instructions.md` exists, load it with:
@.github/aw/instructions.md

Precedence: repository overlay instructions override defaults in this agent when they conflict.
```

**Default + repository overlay + explicit precedence** beats "write it in two places and hope the model guesses".

---

## 2. Give it a check: something that decides "done"

This line is the heart of the chapter:

> Claude stops when the work looks done. If it has nothing to run that tells it whether the work actually *is* done,
> "looks done" is all it has to go on.

Four levels, from loose to strict:

| Level | Approach | Sufficient when |
|---|---|---|
| 1 | say "run the tests until they pass" in the prompt | one-off task |
| 2 | set a goal (`/goal all tests pass and lint is clean`), checked by another model every turn | long or background runs |
| 3 | write "run X before committing" in `AGENTS.md`, require the output in the PR template | day-to-day collaboration |
| 4 | CI required check / a `Stop` hook blocks "finishing" without it | must always hold |

**The single highest-value line**: if the repo already has tests/lint/typecheck, the most useful line in `AGENTS.md`
is **the command that runs it**.

---

## 3. Give it boundaries: what must be deterministic

Three official examples, usable as-is:

| Rule | Written in `AGENTS.md` | Promoted to deterministic |
|---|---|---|
| Do not read `.env` | usually obeyed | `permissions.deny: ["Read(./.env)"]` |
| format after editing | often forgotten | a `PostToolUse` hook runs the formatter |
| do not touch `migrations/` | occasionally worked around | `Edit(./migrations/**)` deny, or a hook with `exit 2` |

Two rules of thumb:

- **Don't use `prompt`/`agent` hooks for enforcement** — a model deciding is not deterministic. Use `command`/`http`.
- If "the hook itself crashes" must also block, add `onFailure: "block"`.
- Deterministic mechanisms are a **scarce resource**: reserve them for "no exceptions", or the repo becomes a maze.

---

## 4. Session mechanics: which mode when

| Situation | Do | When **not** to | Cost |
|---|---|---|---|
| Change spans many files, direction unclear | plan mode first, then execute (official permission modes) | the plan is already clear — the extra round trip is just delay | no extra call, one more exchange |
| Many unrelated files to touch | dispatch a subagent with its own context ([Subagents](https://code.claude.com/docs/en/sub-agents)) | tasks depend on each other and must share intermediate results | each subagent re-reads the relevant files; 3 ≈ 3 contexts |
| Several tasks in parallel, files would collide | one worktree per task ([Worktrees](https://code.claude.com/docs/en/worktrees)) | they all edit the same file | disk + dependency install; slower first run |
| Need heavy search/reading to locate something | let a subagent search; return only the conclusion | one or two files would find it | one independent read, conclusion comes back |
| Long run, unattended | set a goal + a runnable check + a budget cap (`--max-turns` / `--max-budget-usd`) | there is no runnable check — unattended runs amplify errors | billed per token and per turn |

### Get the subagent arithmetic right

The official list is about **when subagents pay off**:

- running independent work in parallel so the whole task finishes sooner;
- keeping long output (a full test run, a wide search) out of the main conversation, where it would otherwise ride along;
- getting a reviewer that hasn't seen how the code was written;
- giving a task **fewer tools** (e.g. a read-only reviewer).

The mechanism behind the cost: **a subagent has its own context window, so it must re-read the relevant files.**
In a repo with large files and deep dependencies, "dispatch a subagent to look" can cost more than looking yourself.
**It is not free parallelism; it trades context for isolation.**

A related quality effect: **the fuller the context, the worse the judgement.** "Short root file, procedures in skills,
searches in subagents" is not tidiness — it protects quality.

The docs also note that broad codebase searches are delegated to the built-in Explore agent, and side tasks fork and run
in the background by default — **many of these switches are not yours to make**; at least know the arithmetic.

---

## 5. Counter-examples

| Counter-example | Problem | Fix |
|---|---|---|
| Turning every rule into a hook | unmaintainable; the model loses room to judge | promote only "no exceptions" rules |
| A 500-line `AGENTS.md` | paid for every session, and compliance drops | split past 200 lines, or switch to the router shape |
| No runnable check, only human review | you become the test suite | give it one pass/fail command |
| Telling the agent to "mind the code style" | not executable | provide formatter + lint commands |
| Five unrelated changes in one session | context pollution, files collide | split into subagents / worktrees |
| A `prompt` hook as a safety gate | still a model decision | `command` hook with `exit 2` |

---

## 6. Criteria

**Must hold (if not, the practice isn't in place)**

- [ ] Is there **one command** that tells the agent whether it got it right?
- [ ] When was that command last actually run?
- [ ] Is any "no exceptions" rule still only written in a document?
- [ ] Are subdirectory conventions layered, or all crammed into the root file?

**Situational (fine to skip, but be able to say why)**

- [ ] Conversely: has a rule with legitimate exceptions been frozen into a hook?
- [ ] Are multi-step procedures in skills, or in the root file?
- [ ] When isolation mattered, did you dispatch a subagent, or dump the search results into the main thread?

> These are not a score. A full checklist doesn't mean the practice is in place, and an incomplete one isn't a problem —
> **the reason matters more than the tick.**

---

## 7. Sources

| Claim | Source |
|---|---|
| Deterministic vs non-deterministic instructions; "let the model judge most of the time" | [Best practices · Deterministic and non-deterministic instructions](https://code.claude.com/docs/en/best-practices) |
| "Give Claude a check it can run" with a pass/fail result; the four tightening levels | ibid · Give Claude a check to run |
| Rules with no exceptions → hook / deny / managed settings; `onFailure: block` | ibid · Enforce the rules that can't have exceptions |
| Short root file, per-directory layering, `claudeMdExcludes`, per-directory skills | [Set up Claude Code in a monorepo](https://code.claude.com/docs/en/large-codebases) |
| Load order and scope | [How Claude remembers your project](https://code.claude.com/docs/en/memory) |
| A real overlay-with-precedence example | `cli/cli`'s `.github/agents/agentic-workflows.md` (sampled) |
