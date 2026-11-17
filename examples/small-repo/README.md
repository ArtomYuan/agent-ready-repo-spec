# small-repo — the router shape

**Hypothetical project**: `acme/fleet`, a CLI plus a thin SDK. One team, one CI workflow, one generated directory.
That is all the constraint surface a repository of this size has.

**What this demonstrates**: every convention fits in about a dozen lines, so the root file does two things only —

1. **points** at the documents that actually hold the detail (`docs/architecture.md`, `CONTRIBUTING.md`);
2. **states the one rule people get wrong** (never hand-edit the generated client) with the command that keeps them
   honest (`make check`).

Adapted from `microsoft/vscode/AGENTS.md`, which is eight lines and does exactly this.

## Pros

- costs almost nothing per session, so it survives
- almost cannot rot: two links and one rule
- nobody hesitates to edit it

## Cons

- **no "why"** — when a situation is not covered, the agent guesses
- the linked documents can drift from the one sentence at the door
- **no automation map**, so workflows belong to nobody

## When to leave this shape

See the parent [README](../README.md#when-to-move-from-small-to-medium). The first trigger is usually the second
workflow or the first generated directory that is not obvious from the file name.