# ADR-0007: cursor pagination for list endpoints

- Status: Accepted
- Date: 2026-11-18
- Deciders: @maintainer, agent: <tool> (proposal only)

## Context

`GET /fleet/vehicles` uses `page` / `page_size`. Under concurrent writes, rows shift between pages: items are
duplicated or skipped, and `total` is a lie by the time the client reads page 3. Support tickets follow.

## Options

1. **Keep `page` / `page_size`** — no client changes; the duplication bug stays and gets worse as the table grows.
2. **Cursor (keyset) pagination** — stable under writes, four endpoints to change, one release of dual support.
3. **Snapshot pagination** (server-side cursor over a materialised set) — strongest consistency, but adds state to the
   server and a cleanup job; operational cost nobody wants to own yet.

## Decision

Option 2. Best consistency-to-cost ratio: no server state, and the compatibility window is short enough to schedule.

## Consequences

- Positive: stable pagination; deep pages get faster because there is no `OFFSET`.
- Negative: clients can no longer jump to an arbitrary page; `total` is only returned on the first page.
- Migration: `page` / `page_size` keep working until v3.0, then are removed. Client SDK ships both.
- Cost accepted: two pagination paths for one release, and a docs update in two places.

## Revisit

If clients demand jump-to-page, option 3 becomes worth its operational cost. Otherwise leave this alone.