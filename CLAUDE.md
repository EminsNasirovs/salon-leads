# Outreach Leads Tracker — context

A shared, real-time CRM-lite for cold-outreach to Latvian beauty salons. Two people
use it to track who has been contacted. Plain static HTML + Supabase, no build step.

## Live deployment
- **Repo:** https://github.com/EminsNasirovs/salon-leads  (this `outreach/` folder is the repo root)
- **Hosting:** GitHub Pages → served at `https://eminsnasirovs.github.io/salon-leads/`
- `index.html` IS the published tracker (Pages serves repo root).
- Local dev: from the parent folder run `node ../server.js`, open `http://localhost:5173/outreach/`.

## Files
- `index.html` — the tracker. Supabase auth gate + card UI + realtime. **Source of truth UI.**
- `leads.html` — OLD localStorage-only version, kept as a backup. Not wired to Supabase.
- `supabase-schema.sql` — the DB schema; run in Supabase SQL Editor to (re)create the `leads` table.
- `dm-karte.html` — Leaflet map of prospects (separate tool). Data inline in `const LEADS`.
- `prospects_geo.json` — ~243 geocoded prospects (feeds map work; not used by index.html).
- `beauty-salon-leads.csv`, `instagram-dm-batch-*.md` — research/outreach artifacts.

## Supabase
- **Project ref:** `wcwugxgyylvdorsrqzep`  → URL `https://wcwugxgyylvdorsrqzep.supabase.co`
- The **anon/public** key is hard-coded in the CONFIG block at the top of `index.html`.
  This is safe to commit — data is protected by RLS + the fact that only the two hand-created
  accounts can authenticate (new signups are disabled).
- **NEVER** put the `service_role` / secret key in any committed file or client-side code.
- Region: EU (Frankfurt).

### Table `public.leads`
Columns: `id, name, type, city, address, phone, email, ig, fb, website, booking, note,
priority('hi'|'med'|'low'), comment, outreached(bool), contacted_by, contacted_at,
deleted(bool), created_at, updated_at`. `updated_at` auto-touched by trigger.

- **Deletes are soft** (`deleted=true`); RLS has no delete policy on purpose. "Restore deleted"
  flips `deleted` back to false for all rows.
- Realtime enabled (`supabase_realtime` publication + `replica identity full`), so edits by
  one user appear live in the other's browser.
- RLS: authenticated users can select/insert/update everything; no anon access.

### Auth setup (one-time, done in dashboard)
- Email provider on; "Allow new signups" OFF; "Confirm email" OFF.
- The two user accounts are created by hand in Authentication → Users.

## How the page works (index.html)
- ES module imports `@supabase/supabase-js@2` from esm.sh (no bundler).
- `SEED` = the original 66 leads, used ONCE to populate an empty table via the "Import
  starter leads" button (`seedToRow()` maps short keys n/t/c/... → DB columns).
- After seeding, the DB is the source of truth. `load()` fetches all rows; `render()` groups by
  priority (hi/med/low). Edits go through `patch(id, fields)` = optimistic local update + DB write.
- Marking "Outreached" sets `outreached=true, contacted_by=<my email>, contacted_at=now()`,
  shown as "✓ by email · 15 Jun 18:40".
- `subscribe()` opens a realtime channel and patches `state` on any change.

## Conventions
- Priority codes: `hi` (no website — hottest), `med` (outdated site), `low` (has a decent site).
- Keep the dark gold theme (`--gold #c9a96a`, `--bg #0f0e0f`). Match existing card markup.
- Commit/push only when asked. Pages auto-deploys from `main` on push.
