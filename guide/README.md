# The guidance

**English** · [简体中文](README.zh-CN.md)

This directory is **guidance**, not a verdict. Whether — and how much — to use it is up to the repository that adopts it.
But the decision should be made **once**, and it should **live inside the adopting repository** — see [00-adoption decisions](00-接入决策.md).

It answers six questions:

1. Which tier to adopt, and where to record that decision
2. What docs a GitHub repository should have
3. How the repository should be laid out
4. How each of those docs should be written
5. How an agent should be used on the repository, and how to govern it when agents write many of the commits
6. Where state and to-dos live when sessions or agents change

`rules/`, `checker/` and `templates/` are supporting tools and samples — **they do not decide for you and do not act for you**.

## Chapters

| Chapter | Content | Language |
|---|---|---|
| [**00 · Adoption decisions**](00-接入决策.md) | eleven options, decided once, every "adopted" needs an enforcement point | [中文](00-接入决策.zh-CN.md) |
| [**01 · What docs a repo should have**](01-该有什么文档.md) | three tiers (platform / collaboration / agent), a ten-repo survey, when you can skip | [中文](01-该有什么文档.zh-CN.md) |
| [**02 · Repository layout**](02-目录结构.md) | root-directory traffic lights, `.github/` vs `.claude/`, three AGENTS.md shapes | [中文](02-目录结构.zh-CN.md) |
| [**03 · How to write each doc**](03-文档该怎么写.md) | README / AGENTS.md / CLAUDE.md / CODEOWNERS / ADR / PR template / CHANGELOG: skeleton, counter-examples, criteria | [中文](03-文档该怎么写.zh-CN.md) |
| `04 · Using an agent` | deterministic vs non-deterministic instructions, giving it a runnable check, session and cost | — |
| `05 · Governing agent participation` | who may change what, when work may start, how it is judged, how it is recorded and reverted | — |
| `06 · Where information lives` | one criterion (rate of change → medium); planning: scope/order/progress; running: state/to-dos/handover; releasing | — |

> **Translation status**: chapters 00–03 are in English; 04, 05, 06 are still Chinese only.
> The order and rules are in [ADR-0007](../docs/adr/0007-bilingual-default-english.md).
> Rule IDs, `check.kind` values and file paths are never translated.

## How to read

- **First time adopting** → read **00**, decide the options, record them in your own repo, then continue.
- Just want to write one file correctly → read the matching section of **03**, follow the skeleton, then check yourself against the counter-examples.
- Starting a repository → read 01 → 02 → 03.
- Handing the repo to an agent → **04**; if agent commits are becoming common, **05**.
- **Planning: where do scope, order and progress go** → **06** §1. **Releasing** → **06** §2.
- **Switching sessions or agents** → **06** §3.
- Want to know what is missing → run `checker/spec-check.ps1` (see the repo README). It reports facts; it does **not** grade your chosen tier.

## One criterion that runs through everything

> **Every line of documentation must answer: what does the reader do next?**

If a sentence cannot answer that, delete it.
