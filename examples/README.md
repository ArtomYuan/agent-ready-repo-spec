# Examples — two ends of one spectrum

These are **not** two templates to pick by repository size. They are the two ends of the same criterion:
*how many layers does the convention need?*

| | [`small-repo/`](small-repo/AGENTS.md) | [`medium-repo/`](medium-repo/AGENTS.md) |
|---|---|---|
| Root `AGENTS.md` | ~12 lines — every convention lives there | ~65 lines — split into sections |
| Where detail goes | nowhere; there is no detail | pushed down (subdirectory files, `CONTRIBUTING.md`, ADRs) |
| Shape | **router**: point at the real document, plus the one rule people get wrong | **constraint + command + validation + automation map** |
| Needs "why" written out | no room for it | yes, partly — the reason behind a constraint decides whether an agent works around it |
| Rots | slowly | faster: commands expire, workflows get renamed |

Both follow the same test: **this is not completeness documentation, it is what an agent must load every session.**

## How to choose

```
1. Can every convention fit in one screen, with no "go read this next"?   → small
2. Do you have generated files, several entry points, or more than one CI job?  → medium
3. Is there a dedicated maintainer AND a single team?                     → only then consider the all-in-one shape
```

## When to move from small to medium

Any one of these:

- the root file passes **200 lines**;
- someone says "I thought I wrote that down" twice;
- a newcomer (or an agent) asks the **same question twice**;
- you add a second workflow, or your first generated file.

You do not rewrite when you move — you **cut it in two**: what must be known every session stays at the root,
what must be looked up becomes a link.

## Where these shapes come from

Nothing here is my taste. Each section is attributed to a repository that actually does it:

| Pattern | Source |
|---|---|
| Router in ~8 lines, pointing at the real instructions | `microsoft/vscode/AGENTS.md` |
| Constraints as "never hand-edit this; do this instead" | `kubernetes/kubernetes/AGENTS.md` |
| Communication preferences (tone) as a real section | `kubernetes/kubernetes/AGENTS.md` |
| `Validation` with paste-and-run commands | `openai/openai-python/AGENTS.md` |
| `Automation map`: one line per workflow, saying what it owns | `openai/openai-python/AGENTS.md` |
| PR template asking whether AI was used | `kubernetes/kubernetes` (per its `AGENTS.md`) |

Raw samples and the full survey: [`docs/evidence/2026-11-18-agent-docs-sampling.md`](../docs/evidence/2026-11-18-agent-docs-sampling.md).

## Two places where real repositories disagree — you decide

**1. `Co-authored-by` attribution.** This library's checklist (`R029`) suggests *keeping* the agent trailer, because it
is the audit trail. `kubernetes/kubernetes` forbids it: no `Co-authored-by`, no `@mentions`, no `fixes #...` in commit
messages — attribution goes into the PR description and an explicit "AI was used" statement instead.

Both are coherent. Keeping the trailer gives you "which commits came from a model" in `git log`; banning it keeps the
history clean and puts attribution where a human reviewer reads it. **`R029` is `should`, not `must`, for exactly this
reason.** `medium-repo/README.md` shows both.

**2. File language.** All samples here are English because the repositories they were taken from are English.
Your repository's agent instructions should be in **the language you talk to your agent in** — see
[`templates/prompt-locale.md.tmpl`](../templates/prompt-locale.md.tmpl).

## What these examples deliberately leave out

- No tool-specific instruction files or tool-specific asset directories — they are the adopter's choice, not the library's
- No workflow files: the examples describe *how to describe* automation, not what your CI should run
- No filled-in numbers (test counts, coverage): those rot fastest of all
