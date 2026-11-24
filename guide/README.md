# The guidance

**English** · [简体中文](README.zh-CN.md)

This directory is **guidance**, not a verdict. Whether — and how much — to use it is up to the repository that adopts it.
But the decision should be made **once**, and it should **live inside the adopting repository** — see [00-adoption decisions](00-接入决策.md).

It answers eight questions — one per chapter:

1. Which tier to adopt, and where to record that decision
2. What docs a GitHub repository should have
3. How the repository should be laid out
4. How each of those docs should be written
5. How an agent should be used on the repository
6. How to govern it when agents write many of the commits
7. Where state, to-dos and handovers live when sessions or agents change — and how a release is decided
8. Which repository settings to turn on, and the one that can lock you out

`templates/` holds samples only — **it does not decide for you and does not act for you**; this library ships no checker ([ADR-0009](../docs/adr/0009-spec-only-no-tooling.md)).

## Chapters

| Chapter | Content | Language |
|---|---|---|
| [**00 · Adoption decisions**](00-接入决策.md) | eleven options, decided once, every "adopted" needs an enforcement point | [中文](00-接入决策.zh-CN.md) |
| [**01 · What docs a repo should have**](01-该有什么文档.md) | three tiers (platform / collaboration / agent), a ten-repo survey, when you can skip | [中文](01-该有什么文档.zh-CN.md) |
| [**02 · Repository layout**](02-目录结构.md) | root-directory traffic lights, `.github/` vs the tool-specific asset directory, three AGENTS.md shapes | [中文](02-目录结构.zh-CN.md) |
| [**03 · How to write each doc**](03-文档该怎么写.md) | README / AGENTS.md / the tool-specific instruction file / CODEOWNERS / ADR / PR template / CHANGELOG: skeleton, counter-examples, criteria | [中文](03-文档该怎么写.zh-CN.md) |
| [**04 · Using an agent**](04-Agent怎么用.md) | deterministic vs non-deterministic instructions, giving it a runnable check, session and cost | [中文](04-Agent怎么用.zh-CN.md) |
| [**05 · Governing agent participation**](05-Agent参与怎么管理.md) | who may change what, when work may start, how it is judged, how it is recorded and reverted | [中文](05-Agent参与怎么管理.zh-CN.md) |
| [**06 · Where information lives**](06-信息该放哪.md) | one criterion (rate of change → medium); planning: scope/order/progress; state/to-dos/handover; releasing | [中文](06-信息该放哪.zh-CN.md) |
| [**07 · Which settings to turn on**](07-该开哪些设置.md) | merging, rulesets, who can bypass, Actions defaults, security, and the one setting that locks you out | [中文](07-该开哪些设置.zh-CN.md) |

> **Both languages are first-class** (ADR-0008): every chapter exists in English and in Chinese, maintained in the same PR. Neither is a "mirror".
> The order and rules are in [ADR-0007](../docs/adr/0007-bilingual-default-english.md).
> Rule IDs, file paths, commands and template placeholders are never translated.

## How to read

- **Want to see a finished file, not a skeleton** → [examples/](../examples/README.md) (two worked samples side by side: router-shaped and layered)
- **First time adopting** → read **00**, decide the options, record them in your own repo, then continue.
- Just want to write one file correctly → read the matching section of **03**, follow the skeleton, then check yourself against the counter-examples.
- Starting a repository → read 01 → 02 → 03.
- Handing the repo to an agent → **04**; if agent commits are becoming common, **05**.
- **Planning: where do scope, order and progress go** → **06** §1. **Releasing** → **06** §2.
- **Switching sessions or agents** → **06** §3.
- Want the switch list → [07 · Which settings to turn on](07-该开哪些设置.md).
- Want to know what is missing → walk [spec/rules/README.md](../spec/rules/README.md). It reports facts; it does **not** grade your chosen tier.
- Need the concrete file name behind a generic term → [mechanism map](../spec/mechanism-map.md) (appendix, non-normative).

## One criterion that runs through everything

> **Every line of documentation must answer: what does the reader do next?**

If a sentence cannot answer that, delete it.
