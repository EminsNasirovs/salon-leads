# Beauty Salon Outreach Leads

Interactive dashboard of beauty-salon outreach leads (Riga, Jurmala, Liepaja, Jelgava).

**Live dashboard:** https://eminsnasirovs.github.io/salon-leads/

## Features
- Filter by priority (High / Medium / Low) and full-text search
- Per-lead editable priority + notes (saved in your browser)
- **Outreached checkbox** — tick a lead once you've contacted it; it gets a "✓ Sent" badge, dims, and counts toward the outreach progress tracker. Use **Hide outreached** to focus on who's left.
- Delete / restore leads

All edits (priority, notes, outreached status, deletions) persist in your browser's `localStorage` — they are private to your machine and not committed back to the repo.

## Files
- `index.html` — the dashboard (also `leads.html`)
- `beauty-salon-leads.csv` — raw lead data
