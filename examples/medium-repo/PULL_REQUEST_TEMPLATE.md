## What changed

<!-- one sentence, then 2–5 bullets -->

## Why

Closes #

## Impact

- [ ] Generated files changed (→ must come from `make codegen`, not a hand edit)
- [ ] Public API or data format change (→ CHANGELOG + docs)
- [ ] New dependency (→ state the reason and the maintenance cost)
- [ ] Database migration (→ include the rollback script)

## How it was verified

<!-- paste the real output of `make check`; "tested" is not evidence -->

```sh
$ make check
...
```

## Was AI used?

<!-- Every AI-assisted PR answers this. "No" is a valid answer. -->

- [ ] No AI assistance
- [ ] AI assisted: which parts, and what did you review line by line?

## Self-check

- [ ] Forbidden areas untouched (`migrations/` on main, generated directories)
- [ ] Behaviour change recorded in `CHANGELOG.md`
- [ ] Design change recorded in an ADR

## What the reviewer should look at closely

<!-- Say plainly which parts you are unsure about. This section matters more than the rest. -->