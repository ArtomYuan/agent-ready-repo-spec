# medium-repo — constraint + command + validation

**Hypothetical project**: `acme/fleet`, grown up: a CLI, a published SDK, one generated client, three workflows.
Multiple constraints now compete for the agent's attention, so the root file is **split into sections** instead of
pointing at one document.

**What this demonstrates** — each section copied from a repository that actually ships it:

| Section | Source |
|---|---|
| `Constraints` written as "never hand-edit this; do this instead" | `kubernetes/kubernetes/AGENTS.md` |
| `Communication` (tone is configurable) | `kubernetes/kubernetes/AGENTS.md` |
| `Validation` with paste-and-run commands | `openai/openai-python/AGENTS.md` |
| `Automation map` — one row per workflow | `openai/openai-python/AGENTS.md` |
| PR template asking whether AI was used | `kubernetes/kubernetes` (per its `AGENTS.md`) |

## Pros

- covers the failure modes that actually cost time: generated files, commands that fail for environment reasons,
  workflows nobody knows the owner of
- every command is pasteable, and the "common failure" column is why it is worth reading
- the automation map gives each workflow an owner

## Cons

- **every line eats the per-session budget, and every line rots** — commands expire, workflows get renamed
- writing it requires knowing the repository's real traps; copying someone else's file produces decoration
- if nobody maintains it, it becomes confidently wrong, which is worse than absent

## The two decisions this example leaves to you

### 1. Attribution: keep the trailer, or ban it?

This file uses **neither** — it does not mention `Co-authored-by`, because that is your call. The two real positions:

| Position | How it looks | Why |
|---|---|---|
| Keep the agent trailer (this library's `R029`, a `should`) | `Co-authored-by: <agent> <noreply@…>` in the commit; `git log` shows which commits came from a model | audit trail lives with the code |
| Ban it (`kubernetes/kubernetes`) | no `Co-authored-by`, no `@mentions`, no `fixes #…` in commit messages; attribution moves to the PR | commit history stays human-readable; attribution sits where reviewers read it |

If you choose to ban it, say so in `## Constraints` explicitly, otherwise an agent that learned the trailer convention
elsewhere will add it. If you choose to keep it, say which trailer format.

### 2. Language

This example is English because the repositories it came from are English. **Your file should be in the language you
talk to your agent in** — declare it in `## Language` (see [`templates/prompt-locale.md.tmpl`](../../templates/prompt-locale.md.tmpl)).

## When this shape is not enough

If the root file passes 200 lines, split it: per-directory `AGENTS.md` files hold only the delta, and procedures move to
`docs/`. Do not grow the root file — see [guide/02](../../guide/02-目录结构.md) for the routing pattern.