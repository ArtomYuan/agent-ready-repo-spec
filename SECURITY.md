# Security Policy

[English](SECURITY.md) · [简体中文](SECURITY.zh-CN.md)

## Supported versions

Only the latest `specVersion` gets fixes. On an older one, upgrade first.

| Version | Supported |
|---|---|
| 1.x | ✅ |

## Reporting a vulnerability

**Do not open a public issue.** Use GitHub's private entry: repository page → Security → *Report a vulnerability*.

Include:

- the affected `specVersion`, plus the exact file and section;
- the smallest reproduction: which rule, template line, or documented claim fails, and against what (a repository layout, an observed platform behaviour, an official doc link). **Do not paste real secrets**;
- the impact class — pick one, it changes what we do next:
  - **wrong criterion** — the rule calls a healthy repository broken, or a broken one healthy;
  - **harmful template** — copying a template line *weakens* a repository (an over-broad `permissions`, a gate that never fires);
  - **stale reference** — a path, command, or platform behaviour written here no longer holds;
  - **instruction injection** — something in this library gets followed as an instruction by an agent that reads it;
- what you expected instead.

We acknowledge within **3 working days** and give an assessment within **10 working days**.

## This repository's own risk surface

There is no executable code here ([ADR-0009](docs/adr/0009-spec-only-no-tooling.md)), so there is no code to exploit.
What *is* executable is **the text**: a repository that adopts this library feeds it to an agent as instructions.
Three real surfaces:

1. **Documentation is executed as instructions.** [spec/agent-playbook.md](spec/agent-playbook.md),
   [spec/rules/README.md](spec/rules/README.md) and [AGENTS.md](AGENTS.md) are written in the imperative
   ("follow this order, do not skip"). A stale or wrong sentence there is not a typo — it is a bad instruction every
   downstream agent obeys. This is why there is exactly one source of truth for the rules, and why ADR-0009 deleted the
   checker instead of keeping two descriptions of the same rule.
2. **Templates weaken a repository when copied blind.** [templates/settings.json.tmpl](templates/settings.json.tmpl)
   and [templates/CODEOWNERS.tmpl](templates/CODEOWNERS.tmpl) set the permission baseline and the review gate.
   A placeholder left in place, or a `deny` list that does not match the target's layout, produces a gate that looks
   switched on and is not. Treat every template as a diff to review, not a file to drop in.
3. **External behaviour drifts.** Rules cite GitHub and agent-tool behaviour — load order, trailer format,
   required-check semantics. Those change without notice, so a rule that was true when written can silently become a
   false instruction. Evidence in [docs/evidence/](docs/evidence/) is dated for exactly this reason: an undated claim
   cannot be re-checked.

## Known non-issues

- Nothing here runs on your machine: no script, no dependency manifest, no install step.
- Nothing here phones home. The only automation is [`.github/workflows/docs.yml`](.github/workflows/docs.yml); it runs
  on GitHub's runners, checks this repository's own markdown (links, bilingual pairing), and holds no secrets
  (`permissions: contents: read`).
