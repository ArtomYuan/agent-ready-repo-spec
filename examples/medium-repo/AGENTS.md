# AGENTS.md — acme/fleet

> Everything an agent needs **every session**. Project history and architecture: [`docs/architecture.md`](docs/architecture.md).
> Contribution process and review SLA: [`CONTRIBUTING.md`](CONTRIBUTING.md). Design decisions: [`docs/adr/`](docs/adr/).

## Language

Talk to me and write documentation in **English**. Do not translate: rule IDs, file paths, commands, code identifiers.

## Constraints

- **Generated code is read-only.** `src/client/**` and `db/schema.sql` are produced by `make codegen`. Never hand-edit
  them; change `api/openapi.yaml` or `db/schema.rb` and regenerate. `make check` fails if they drift.
- **`pnpm-lock.yaml` is generated.** Use `pnpm add` / `pnpm update`, never edit it.
- **`packages/core` must not import from `packages/cli`.** The dependency points one way; a backwards import breaks the
  published SDK for consumers who do not install the CLI.
- **Do not touch `migrations/`** that are already on `main`. Add a new one.

## Commands

| Purpose | Command | Common failure |
|---|---|---|
| Install | `pnpm install --frozen-lockfile` | fails after a dependency bump — run `pnpm install` locally first |
| Build | `pnpm build` | must run before `test`; tests import from `dist/` |
| Test (unit) | `pnpm test` | — |
| Test (e2e) | `pnpm test:e2e` | needs `docker compose up -d db` |
| Regenerate code | `make codegen` | requires `api/openapi.yaml` to be valid; run `make spec-lint` first |
| Everything CI runs | `make check` | this is the one to run before you report done |

## Validation

Before saying a task is complete, paste the output of:

```sh
make check          # lint + typecheck + unit + e2e + drift check on generated files
```

`make check` includes the generated-file drift check. If it fails with "generated files are stale", run
`make codegen` and commit the result — do not edit the generated file by hand to make it pass.

## Automation map

| Workflow | What it owns |
|---|---|
| `ci.yml` | lint, typecheck, unit + e2e, generated-file drift; runs on every PR |
| `release.yml` | tags, builds, publishes the SDK; manual dispatch only |
| `codegen-sync.yml` | weekly: regenerates from the spec and opens a PR if it drifted |

If you add a workflow, add its row here. An unlisted workflow is one nobody owns.

## Communication

Dry and direct. No preamble, no flattery, no "great question". If something is a guess, say it is a guess and give the
command that would settle it.

## Forbidden

- Do not push to `main`; branch and open a PR (the ruleset will reject a direct push).
- Do not add a dependency without saying why and what it costs to maintain.
- Do not read `.env*` or `secrets/`; use the fixtures in `test/fixtures/`.

## Known pitfalls

- On Windows, `pnpm build` before `pnpm test`, otherwise tests import a stale `dist/`.
- `pnpm test:e2e` silently skips when `DATABASE_URL` is unset — a green run may have tested nothing.
- Do not use `moment`; the project standardised on `date-fns`.

## When unsure

Stop and ask. Present 2–3 options with trade-offs. Do not widen the task on your own.