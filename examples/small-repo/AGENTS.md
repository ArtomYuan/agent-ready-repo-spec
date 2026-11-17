# AGENTS.md — acme/fleet

Instructions for AI coding agents working in this repository.

Project overview, module boundaries and design notes live in
[`docs/architecture.md`](docs/architecture.md); contribution rules, test matrix and review process live in
[`CONTRIBUTING.md`](CONTRIBUTING.md). Read whichever you need — this file only carries what you must not get wrong.

## The one thing people get wrong

`fleet` ships a **generated** OpenAPI client. Never edit `src/client/**` by hand — it is overwritten by
`make codegen`. Change the spec in `api/openapi.yaml`, then regenerate.

Run `make check` before you say you are done. It is the same command CI runs.