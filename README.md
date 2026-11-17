# agent-ready-repo-spec

A **guidance library**: what a GitHub repository should look like when an agent takes part in its development —
which docs it needs, how to lay it out, how to write each file, how to use an agent, and how to govern it when
agents write many of the commits.

- **Documentation only — no rule engine.** No checker, no generator, no package manifest. The one piece of automation is the platform-level required checks in [`.github/workflows/docs.yml`](.github/workflows/docs.yml) (link check + bilingual pairing); they validate the docs themselves and never the rules — see [ADR-0009](docs/adr/0009-spec-only-no-tooling.md).
- **No language, no tool, no runtime required.** You read it, copy the templates, and walk the checklist.
- **Bilingual, both first-class** ([ADR-0008](docs/adr/0008-bilingual-equal-status.md)): English and Chinese are peers,
  maintained in the same PR. Chinese mirror: [README.zh-CN.md](README.zh-CN.md).

## How to use it

1. **Read the chapters you need** — start with [guide/README.md](guide/README.md).
2. **Walk [spec/checklist.md](spec/checklist.md)** — 37 items, grouped L0–L3. For each: *do we have it, and if not, why not?*
   The reason matters more than the tick.
3. **Copy what fits** from [templates/](templates/) — `AGENTS.md`, PR template, CODEOWNERS, ADR, adoption record.

That's the whole workflow. There is no command to run, and that is deliberate.

## What's inside

| Path | Contents |
|---|---|
| [guide/](guide/README.md) | Eight chapters: adoption decisions · what docs · layout · how to write each doc · using an agent · governing agent participation · where information lives · which settings to turn on |
| [spec/](spec/README.md) | How to read the spec: maturity levels, severities, version policy · **[checklist.md](spec/checklist.md)** · agent reading order |
| [templates/](templates/) | Files to copy into your repository, with `{{PLACEHOLDER}}` markers |
| [docs/](docs/index.md) | ADRs (why each decision), dated evidence from two samplings — 10 repositories' file surface and 12 repositories' agent-instruction files — and the doc map |

## The one criterion that runs through everything

> **Every line of documentation must answer: what does the reader do next?**

If a sentence cannot answer that, delete it.

## Contributing, security, licence

- [CONTRIBUTING.md](CONTRIBUTING.md) — what kinds of contributions are useful, and the flow
- [SECURITY.md](SECURITY.md) — report privately, never in a public issue
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- MIT — see [LICENSE](LICENSE)
