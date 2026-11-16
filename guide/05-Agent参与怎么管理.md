# 05 · Governing agent participation

**English** · [简体中文](05-Agent参与怎么管理.zh-CN.md)

> This chapter is about **what changes once agent commits become common**.
> Sources: Anthropic's [Best practices](https://code.claude.com/docs/en/best-practices),
> [Permissions](https://code.claude.com/docs/en/permissions), [Hooks](https://code.claude.com/docs/en/hooks),
> [Worktrees](https://code.claude.com/docs/en/worktrees); GitHub's branch-protection and CODEOWNERS rules;
> and the agent gates **actually written down** in `cli/cli`, `python/cpython` and `microsoft/vscode`.

---

## 0. Four questions are enough

| Question | Mechanism | Who enforces |
|---|---|---|
| **Who may change what** | branch protection, CODEOWNERS, deny rules, managed settings | platform / harness |
| **When may work start** | contribution eligibility gates, pre-flight checks | rules set by people, followed by the agent |
| **How is it judged** | required checks, PR template, the human's final vote | CI + a person |
| **How is it recorded and reverted** | attribution trailer, CHANGELOG, ADRs, PR discussion, worktrees | tooling + convention |

The official position, in one line:

> **Who has the last word** — Branch protection, a person who approves the merge.

**The agent is never the final judge.** It can be the author and the first reader of a review; it cannot be the one who
approves.

---

## 1. Who may change what: install the gate first

### 1.1 Branch protection is the only truly hard boundary

| Setting | Value | Effect |
|---|---|---|
| Require a pull request | ✅ | no direct pushes |
| Required approvals | ≥1 | a human must look |
| Dismiss stale approvals | ✅ | new commits void old approvals |
| **Require review from Code Owners** | ✅ | makes `CODEOWNERS` real (without it, decoration) |
| Require status checks | `lint`, `test`, … | CI gate |
| Allow force pushes / deletions | ❌ | protects history |
| **Do not allow bypassing** | ✅ | admins must go through the gate too; use a ruleset **bypass list** for emergencies instead of "admins can bypass anything" |

Two notes on bypass:

- This setting decides whether all of the above still holds when someone is in a hurry. The motive is rarely malice —
  it is "I need to ship". Once agents make changes cheap, that motive shows up far more often.
- Exceptions can exist, but they must be **authorised and recorded**: enable `Do not allow bypassing`, name who may
  bypass in the ruleset bypass list, and write down why in an ADR.
  **"Depends on the team" is not a setting; it is a way of forgetting.**

### 1.2 Give the governance surface its own owners

```
/.claude/               @org/agent-ops
/.github/workflows/     @org/agent-ops
/AGENTS.md              @org/agent-ops
```

Rationale: **an agent changing code is work; an agent changing its own permissions and gates is overreach.**
These three must go through a human PR, ideally reviewed by someone other than the author.

### 1.3 Use managed settings at the organisation level

A personal `settings.json` can be edited; **managed settings (pushed by the org) cannot be overridden by the individual.**
Anything that must hold company-wide belongs there. Rules that live in the repository are only "this repo's convention".

---

## 2. When may work start: gates real repositories use

This is the most overlooked practice, and the top repositories all do it — **gate the agent before it starts writing code.**

### `cli/cli`

> Excerpt (fetched 2026-11-17, `AGENTS.md` in `cli/cli`):
>
> "**Do not prepare an unsolicited external upstream pull request to cli/cli.**"
> "Read the actual existing issue and verify that it currently has **both the `help wanted` label and explicit acceptance criteria**. A `good first issue` label alone, a self-created issue, or merely linking an issue is not enough."
> "**Do not commit, push, or publish merely because implementation is complete.**"

Key points:

- **No unsolicited upstream PRs**: it needs `help wanted` **and** explicit acceptance criteria; a `good first issue`
  label alone, a self-created issue, or merely linking an issue does not count;
- issues labelled `core` are off limits;
- if eligibility is absent or ambiguous, **stop implementing**, explain the policy, and do not auto-create
  issues/discussions/comments;
- authorisation is specific: an authenticated identity with **`write` permission** on the repo counts as "someone asked
  for this"; fork ownership, a "please fix this", or a beneficial-looking change does not;
- **"implementation complete" does not mean you may commit, push, or publish.**

### `python/cpython`

> Excerpt (fetched 2026-11-17, `AGENTS.md` in `python/cpython`):
>
> "CPython has a policy on the use of AI tools… All use of AI tools and agents when working on or interacting with CPython must follow it."
> "**Primary directive**: Read the policy before making or proposing any changes."
> "Do not auto-generate issues with AI tools."

Key points: read the policy first; never auto-open issues; and it ships de-duplication commands so "don't open
duplicates" becomes an executable action.

### Four things to copy

1. **An eligibility check before starting** (were you invited? are there acceptance criteria?);
2. **Stop conditions** (ambiguous eligibility → stop; do not widen scope yourself);
3. **Turn "don't" into a command** (a de-duplication search);
4. **Say explicitly that "done" ≠ "may submit"** — commit, push and publish are separate decisions.

---

## 3. How is it judged: three gates

| Gate | Enforced by | Judges |
|---|---|---|
| Machine | CI required checks | does it build, do tests pass, is lint clean |
| Structure | PR template | was "what / why / how verified" filled in |
| Human | the reviewer | intent, edge cases, blast radius, revertibility |

**The two most valuable fields in a PR template**:

- **How it was verified** — require real output; "tested" is not evidence;
- **What the reviewer should look at closely** — turns review from "read the diff" into "check these three things".

---

## 4. How is it recorded: attribution, changes, decisions

| What | Mechanism | Note |
|---|---|---|
| who wrote this commit | **git trailer** (Claude Code writes `Co-Authored-By: <model> <noreply@anthropic.com>` by default) | configured via `attribution.commit`; do not invent a custom `Agent:` line |
| what changed in this version | `CHANGELOG.md` | user-visible changes only, with PR numbers |
| why it was designed this way | `docs/adr/` | options must say why they were rejected |
| what was discussed | PR description and comments | the template forces structure so discussion doesn't scatter |

**Why attribution matters**: it is the only clue that later answers "who wrote this, and can it be reproduced".
Turning it off (`attribution: false` or an empty string) is knowingly discarding auditability — which is why it is the
only `should` among this repo's commit-related rules.

---

## 5. How to isolate and revert

| Tool | Use | Note |
|---|---|---|
| **worktree** | parallel tasks that must not collide | each on its own branch; declare which gitignored files come along via `.worktreeinclude` |
| **small commits** | one purpose per change | a PR mixing refactors cannot be reviewed, nor cleanly reverted |
| **no force push** | history is not rewritten | it is the precondition for reverting |
| **`revert` before "fix forward"** | restore a working state first | the bug fix is a second task |

**The revert test**: can this change be undone with a single `git revert`?
If there is a data migration, an external side effect, or a shipped interface change — that is not a revert, that is an
incident, and it needs a runbook.

---

## 6. Don't let the agent govern itself

A structure worth copying from `cli/cli`'s agent definition:

```markdown
## Repository Instructions Overlay
If `.github/aw/instructions.md` exists, load it with:
@.github/aw/instructions.md
Precedence: repository overlay instructions override defaults in this agent when they conflict.
```

Two ideas:

1. **The agent's defaults and the repository's overlay live in separate places**, and precedence is stated explicitly —
   no "two rule sets fight and the model picks one at random";
2. **The overlay itself lives under `.github/`, governed by CODEOWNERS** — the agent cannot rewrite its own rules.

Likewise, `microsoft/vscode` keeps `agents/`, `skills/`, `instructions/` and `hooks/` under `.github/`, subject to the
same review and permissions as workflows. **Putting an agent's capabilities and its constraints in the same governed
directory** is much harder to bypass than spreading them out.

---

## 7. Organisation scale

| Situation | Do |
|---|---|
| Same baseline across many repos | a public org-level `.github` repo with default `CONTRIBUTING`/`SECURITY`/templates; per-repo files override |
| Rules that must never be overridden | managed settings (neither the individual nor the repo can override) |
| Many tasks in parallel | worktrees + a subagent each; don't serialise five things in one session |
| Long unattended runs | an explicit check + a goal condition + a budget cap (`--max-turns` / `--max-budget-usd`) |

---

## 8. Counter-examples

| Counter-example | Consequence | Fix |
|---|---|---|
| The agent commits straight to main | no review, no rollback point | branch protection |
| CODEOWNERS present but `Require review from Code Owners` off | looks like governance, does nothing | enable the toggle |
| The agent can edit `.github/workflows/` and `.claude/` | it can let itself through | separate owners + deny rules |
| Attribution turned off | you cannot tell which commits came from a model | keep the trailer |
| "Tested" as the only verification | false green | require pasted output |
| One PR mixing three rounds of refactoring | unreviewable, unrevertable | enforce focus; split |
| A `prompt` hook as the security gate | still a model decision | `command` hook + `exit 2` + `onFailure: block` |

---

## 9. Criteria

**Must hold (if not, governance is not installed)**

- [ ] Is branch protection on? Is `Require review from Code Owners` on?
- [ ] Do `/.claude/`, `/.github/workflows/` and `/AGENTS.md` have their own owners?
- [ ] Can an incident be undone with a single `git revert`?
- [ ] Is any "no exceptions" rule still only written in a document?

**Situational (fine to skip, but be able to say why)**

- [ ] Does the agent have an eligibility check and stop conditions?
- [ ] Does the PR template demand "how it was verified" and "what to look at closely"?
- [ ] Can you tell which model wrote a commit (`Co-Authored-By` trailer)?

> These are not a score. A full checklist doesn't mean governance works —
> **being able to say why you skipped something matters more than ticking everything.**
