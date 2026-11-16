# agent-ready-repo-spec

[简体中文](README.zh-CN.md) · **English**

**What docs and structure a GitHub repository should have, and how to govern it when an AI agent helps maintain it — written as rules, so a single command can audit any repository.**

Not another best-practice essay: the rules are **machine-readable JSON**, and the checker turns them into a **self-check list** (present / to add / skipped) with a one-line fix for each gap. Add `-Assess` to also get a score and an achieved level. Both humans and agents can consume the output.

> **Scope of the checker**: it guarantees the **floor** — no missing files, no dead internal links, no duplicated sources of truth.
> It does **not** judge the **ceiling** — whether the docs are any good, whether the architecture makes sense.
> All `[ok]` means "everything required is present", not "this is a good repository".

```
L0 — a human or an agent can pick it up and run it
L1 — outside contributors don't have to ask "how do I submit this?"
L2 — answers can be found, decisions can be traced
L3 — agent changes are rejectable, revertible, and don't rot
```

---

## 30-second start

```bash
git clone <your-fork-url> agent-ready-repo-spec
cd agent-ready-repo-spec
pwsh ./checker/spec-check.ps1 -Target /path/to/the/repo/you/want/to/audit
```

If your Windows execution policy is `Restricted`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\checker\spec-check.ps1 -Target D:\code\my-repo
```

Output looks like this (**example**: the target is an ordinary repo missing 3 items, not this repo itself):

```
spec-check 1.3.0  target: D:\code\my-repo  (checking up to L3)
36 checks: 34 applicable, 2 skipped

L0 — a human or an agent can pick it up and run it
  [ok]   R001  README exists
  [todo] R002  AGENTS.md exists at the repo root  (must)
         > missing: AGENTS.md
         fix: create AGENTS.md with commands, a directory map, hard rules, forbidden areas, known pitfalls
...
31 present · 3 to add · 2 skipped
This is a self-check list, not a rating; add -Assess for a score and an achieved level.
```

## Use as a GitHub Action

```yaml
name: spec
on: [pull_request]

permissions:
  contents: read

jobs:
  spec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<pinned-sha>
      - uses: ArtomYuan/agent-ready-repo-spec@<pinned-sha>   # or @v1 for a quick try
        with:
          level: '3'
          fail-on: 'must'
```

Inputs: `target` (default `.`), `level` (0–3), `fail-on` (`must` | `should` | `none`), `assess`, `git`, `format`.

`v1` is a moving tag: convenient, but it can point somewhere else tomorrow.
For production, pin a **commit SHA** — the same advice this repo gives for every other action
(see [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) and [ADR-0006](docs/adr/0006-github-action-distribution.md)).

## Read the guidance first, then self-check

The **substance of this repo is guidance**: which docs a GitHub repo should have, how it should be laid out,
how to write each file, how an agent should be used, and how to govern it when agents write a lot of the commits.
`rules/`, `checker/` and `templates/` are supporting tools and samples — they do not make decisions for you and do not act on your behalf.

> The guidance text is currently written in **Chinese**. English translation is in progress, chapter by chapter —
> tracked in [ADR-0007](docs/adr/0007-bilingual-default-english.md). File names and rule IDs are identical in both languages.

| I want to know | Go to |
|---|---|
| Which options to adopt, and where to record that decision | [guide/00-接入决策.md](guide/00-接入决策.md) |
| How a specific file should be written (README / AGENTS.md / CODEOWNERS / ADR / PR template / CHANGELOG) | [guide/03-文档该怎么写.md](guide/03-文档该怎么写.md) |
| The full guidance, chapter by chapter | [guide/README.md](guide/README.md) |

## Three ways to use it

| You are | What you need | Start here |
|---|---|---|
| A human who wants to write the docs right | the how-to plus counter-examples | [guide/03-文档该怎么写.md](guide/03-文档该怎么写.md) |
| A human who wants to find gaps | one command, read the `[todo]` lines and fixes | the example above |
| An agent that has to run a repository | read the playbook, then follow the skills | [AGENTS.md](AGENTS.md) · [spec/agent-playbook.md](spec/agent-playbook.md) |
| A CI pipeline that should keep the gate closed | run only `must`, fail the job | [docs/guides/use-in-ci.md](docs/guides/use-in-ci.md) |

## Levels

| Level | Criterion | Typical rules |
|---|---|---|
| **L0** | a human or an agent can take over within 30 seconds | `README` `AGENTS.md` `.gitignore` `LICENSE` `CI` |
| **L1** | outside contributors don't have to ask how to submit | `CONTRIBUTING` `CODEOWNERS` `PR/issue templates` `CHANGELOG` |
| **L2** | answers are findable, decisions are traceable | `SECURITY` `docs/` (incl. `adr/`) `.claude/settings.json` |
| **L3** | agent changes are rejectable, revertible, non-rotting | `AGENTS.md` size/structure, hook targets exist, thin `CLAUDE.md`, no dead references |

Full rule table (generated from `rules/rules.json` — do not edit by hand): [spec/RULES.md](spec/RULES.md)

## What one rule looks like

```json
{
  "id": "R033",
  "level": 3,
  "severity": "should",
  "title": "CLAUDE.md 是薄适配层",
  "check": { "kind": "file-limit", "file": "CLAUDE.md", "regex": "@AGENTS\\.md", "max": 40 },
  "rationale": "CLAUDE.md 与 AGENTS.md 各写一份会形成双事实源，agent 随机选一个生效。",
  "fix": "CLAUDE.md 第一行写 @AGENTS.md，只保留 Claude 专属的少量补充。"
}
```

Three severities: `must` (defect) / `should` (expected) / `may` (bonus). The exit code only follows the threshold you pass with `-FailOn`.

## Adding or changing a rule

```bash
# 1. edit rules/rules.json
# 2. regenerate the human-readable table
pwsh ./checker/gen-rules-doc.ps1
# 3. run the self-test (builds temporary fixtures and asserts engine behaviour)
pwsh ./tests/selftest.ps1
# 4. audit this repo itself
pwsh ./checker/spec-check.ps1 -Target .
```

Rule changes must be reflected in `CHANGELOG.md`; changing what a rule means requires a `specVersion` bump.

## Layout

```
action.yml              GitHub Action entry point (composite)
rules/rules.json        single source of truth (machine-readable)
spec/RULES.md           human-readable table, generated from rules.json
spec/agent-playbook.md  how an agent should run a repository with this spec
checker/spec-check.ps1  the checker (no third-party dependencies)
checker/gen-rules-doc.ps1  regenerates RULES.md
guide/                  the guidance itself, chapter by chapter
templates/              templates to copy into your repository
docs/                   design notes, ADRs, CI integration, evidence
tests/selftest.ps1      fixture-based self-test
```

## Why PowerShell

The rules are JSON and the engine is a thin layer. PowerShell is preinstalled on GitHub-hosted runners for
all three platforms, so no Node/Python runtime is pulled in. To reimplement it in another language,
implement the `check.kind` values listed in `spec/RULES.md` — the JSON contract is what matters.

## License

MIT — see [LICENSE](LICENSE).
