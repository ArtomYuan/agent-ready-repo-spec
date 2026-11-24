# 05 · Governing agent participation

**English** · [简体中文](05-Agent参与怎么管理.zh-CN.md)

> This chapter is about **what changes once agent commits become common**.
> Sources: the vendor documentation excerpted in [evidence](../docs/evidence/2026-11-17-claude-code-docs.md)
> (best practices, permissions, hooks, worktrees, settings); GitHub's branch-protection and CODEOWNERS rules;
> and the agent gates **actually written down** in `cli/cli`, `python/cpython` and `microsoft/vscode`.
> Generic terms for tool mechanisms are used throughout; their mapping to concrete mechanisms lives in the
> [mechanism map](../spec/mechanism-map.md) (appendix, non-normative).

---

## 0. Four questions are enough

| Question | Mechanism | Who enforces |
|---|---|---|
| **Who may change what** | branch protection, CODEOWNERS, the permission declaration (deny list), managed settings | platform / harness |
| **When may work start** | contribution eligibility gates, pre-flight checks | rules set by people, followed by the agent |
| **How is it judged** | required checks, PR template, the human's final vote | CI + a person |
| **How is it recorded and reverted** | session attribution trailer, CHANGELOG, ADRs, PR discussion, worktrees | tooling + convention |

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
/<tool asset dir>/      @org/agent-ops
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
| who wrote this commit | **session attribution trailer** (if your tool adds a `Co-Authored-By: <model> <noreply address>` trailer by default; original wording in [evidence §1](../docs/evidence/2026-11-17-claude-code-docs.md)) | configured via the tool's attribution setting; do not invent a custom `Agent:` line |
| what changed in this version | `CHANGELOG.md` | user-visible changes only, with PR numbers |
| why it was designed this way | `docs/adr/` | options must say why they were rejected |
| what was discussed | PR description and comments | the template forces structure so discussion doesn't scatter |

**Why attribution matters**: it is the only clue that later answers "who wrote this, and can it be reproduced".
Turning it off (the tool's attribution setting set to false or an empty string) is knowingly discarding
auditability — which is why it is the
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
| The agent can edit `.github/workflows/` and the tool-specific asset directory | it can let itself through | separate owners + deny rules |
| Attribution turned off | you cannot tell which commits came from a model | keep the trailer |
| "Tested" as the only verification | false green | require pasted output |
| One PR mixing three rounds of refactoring | unreviewable, unrevertable | enforce focus; split |
| A `prompt` hook as the security gate | still a model decision | a `command` gate hook returning the blocking exit code, plus `onFailure: block` |

---

## 9. Criteria

**Must hold (if not, governance is not installed)**

- [ ] Is branch protection on? Is `Require review from Code Owners` on?
- [ ] Does the tool-specific asset directory, and do `/.github/workflows/` and `/AGENTS.md`, have their own owners?
- [ ] Can an incident be undone with a single `git revert`?
- [ ] Is any "no exceptions" rule still only written in a document?

**Situational (fine to skip, but be able to say why)**

- [ ] Does the agent have an eligibility check and stop conditions?
- [ ] Does the PR template demand "how it was verified" and "what to look at closely"?
- [ ] Can you tell which model wrote a commit (`Co-Authored-By` trailer)?

> These are not a score. A full checklist doesn't mean governance works —
> **being able to say why you skipped something matters more than ticking everything.**
---

## 10. Sources

| Claim | Source |
|---|---|
| "the last word goes to branch protection and the person who approves the merge" | [evidence §3](../docs/evidence/2026-11-17-claude-code-docs.md) |
| how far the deny list, sandbox and managed settings actually bind | [permission declaration and gate hook](../spec/rules/agent-config/permissions.md) |
| gate-hook determinism, the blocking exit code, `onFailure: block` | [permission declaration and gate hook](../spec/rules/agent-config/permissions.md) |
| worktree isolation and the tool's worktree-include file | git worktrees; the include file is a per-tool convention (see the [mechanism map](../spec/mechanism-map.md)) |
| the default `Co-Authored-By` trailer and the attribution setting | [evidence §1](../docs/evidence/2026-11-17-claude-code-docs.md) |
| eligibility gates before starting, "done ≠ may submit" | `AGENTS.md` in `cli/cli` (measured) |
| read the AI policy first, no auto-generated issues, de-duplication command | `AGENTS.md` in `python/cpython` (measured) |
| overlay + explicit precedence; capabilities and constraints under one governed directory | `.github/agents/agentic-workflows.md` in `cli/cli`, `.github/` in `microsoft/vscode` (measured) |
| branch protection and the CODEOWNERS toggle | [About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches) |

---
## Appendix: a self-lock you will hit — required checks pointing at deleted jobs

**Symptom**: four checks on the PR sit at `Expected — Waiting for status to be reported` forever. Nothing fails,
nothing passes, the merge button stays grey. You suspect a quota — it is not.

**Cause**: `required status checks` stores **names**, not jobs. Each name must be reported by *something*.
Delete the workflow or rename a job and the old names have no producer, so they stay **pending forever** —
GitHub will not time out and will not accept results from an earlier commit (only this PR's head commit counts).

**Why it is dangerous**: renaming or deleting CI looks like housekeeping. It is a **self-lock**: main becomes
unmergeable, and no tool will warn you that you just deleted the producer.

**How to check (30 seconds)**

```
the context list in required_status_checks  ⇄  the job names that actually exist in the workflows
The two must match one-to-one. One extra → pending forever
```

**Prevention**

1. **Rename a job in three steps**: add the new-named job (keep the old one) → repoint the ruleset → delete the old job
   in a later PR. **Never rename and re-point in the same PR.**
2. Before touching `workflows/`, write down in `AGENTS.md` which contexts the ruleset depends on — otherwise the next
   person (or agent) has no idea what they are dismantling.
3. Editing a ruleset needs `administration` permission, which **an App token usually does not have** — and the reason
   it is missing is rarely the one you would guess: ticking the permission on the App does **not** make it available.
   The installation has to approve the widened set first; until it does, the key is simply **absent** from
   `token.permissions`. Measured in
   [docs/evidence/2026-11-18-github-app-permission-propagation.md](../docs/evidence/2026-11-18-github-app-permission-propagation.md).
   So **check `token.permissions`, not the App's settings page**, and have the adoption record state who can edit the
   ruleset — otherwise nobody can undo a self-lock.
   The same class of trap waits in the API you use to clean up: `PATCH /repos` **silently ignores** the `topics`
   field (200 OK, nothing changed) — topics live behind `PUT /repos/{owner}/{repo}/topics`. **Read the value back**:
   2xx only means the request was legal, not that every field you sent was accepted.

**Break-glass (treat as `must` in any repository adopting this spec)**

- name who may edit the ruleset / branch protection (a person or team, not "the admins");
- the shortest recovery path: repoint the required-check list, or temporarily disable the `Require status checks` rule;
- after recovery, **write an ADR** saying why it locked and who unlocked it — otherwise it happens again.

---

## Appendix: rules this chapter decides

Navigation only — the criteria themselves live in [spec/rules/README.md](../spec/rules/README.md).

| Rule | What this chapter explains about it |
|---|---|
| `R011` | giving the governance surface its own owners — the first human gate on agent changes |
| `R029` | keeping agent attribution, so "which commit came from a model" stays answerable |
| `R041` | whose commit conventions win when the agent tool ships its own |
| `R044` | why the governance files need their own owner, and why an agent must not edit them |
| `R048` | declaring agent participation at the PR level, alongside the commit-level trailer |
| `R049` | keeping an agent's change individually revertable |
| `R050` | commit history as the one piece of evidence that cannot be written after the fact |
| `R060` | the gates themselves: required PR, required checks, no admin bypass |
| `R062` | the blast radius of whatever credential the agent is holding |

> **This used to be a coverage gap; `1.5.0` closed it.** The gates this chapter argues for were always *structural* —
> verifiable, therefore checklist material — but had no rule ID. They do now: `R060` (protection), `R043`
> (required-check names, see [guide/07](07-该开哪些设置.md)), `R044` (code owners), `R049` (revert path).
> Why they stopped at `should`, and what that costs, is recorded in
> [ADR-0011](../docs/adr/0011-github-management-rules.md).

Evidence: [docs/evidence/2026-11-17-protection-probe.md](../docs/evidence/2026-11-17-protection-probe.md).
