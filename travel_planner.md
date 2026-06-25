# GTA Seasonal Activity App — Project Context for Claude Code

## What This App Is

A calendar-first seasonal activity finder for the Greater Toronto Area.

**Core promise to the user:** "Tell me who you're with, when, and where you are in GTA — I'll show you what's worth doing this weekend."

**Key differentiator:** Calendar-first framing (what's happening *this weekend*) + audience filters. Not an attractions directory. Not a map of places. A time-aware activity guide.

**Target platform:** Android (Google Play Store). iOS is v2.

---

## Tech Stack

| Layer | Tool | Notes |
|---|---|---|
| Frontend | Flutter | Single codebase, Android-first for v1 |
| Database | Firebase Firestore | Free tier (Spark plan) — sufficient for v1 |
| Dev tool | Claude Code on Windows | Primary coding assistant |
| Data curation | Google Sheet → Firestore | Manual curation by owner for v1 |
| Auth | None | No user accounts in v1 |

---

## v1 Scope — What's IN

These are non-negotiable for launch. Do not expand beyond this list without explicit instruction.

1. **Calendar view** — current week + next 4 weeks at a glance
2. **Audience filter** — Family / Kids / Couples / Friends (multi-select)
3. **Event cards** — each showing: event name, date window, GTA region, cost (free/paid/$$/$$$ tiers), audience tags, 2-line description, source link
4. **"This weekend" quick filter** — the killer feature; one tap to show only what's on in the next 2 days
5. **GTA region filter** — Downtown Toronto / West GTA / East GTA / North GTA / Niagara (within striking distance)
6. **Static data** — 30–50 manually curated events loaded from Firestore

---

## v1 Scope — What's OUT

Do not implement any of these. They are v2+ features. If asked to add them, refuse and note they are explicitly deferred.

- User accounts / login
- Push notifications
- User-submitted events
- Reviews or ratings
- In-app maps or directions (show address + "Open in Google Maps" link only)
- Social sharing
- Multi-region (outside GTA)
- Search bar (v1 uses filters only)
- Admin panel (owner edits data directly in Firestore or Google Sheet)

---

## Data Model

### Firestore Collection: `events`

Each document represents one event. Fields:

```
event_id          string      Auto-generated Firestore doc ID
name              string      Display name of the event
description       string      2–3 sentences max. Plain language, no hype.
region            string      One of: downtown_toronto | west_gta | east_gta | north_gta | niagara
start_date        timestamp   When the event window opens
end_date          timestamp   When the event window closes
is_recurring      boolean     True if it repeats (e.g. every Saturday)
recurrence_note   string      Human-readable note if recurring (e.g. "Every Saturday in July")
audience          array       One or more of: family | kids | couples | friends
cost_tier         string      One of: free | paid_low | paid_mid | paid_high
cost_note         string      Short note (e.g. "$15/person", "Free entry, parking $10")
source_url        string      Link to official event page
image_url         string      Optional. Direct image URL for card thumbnail.
active            boolean     Set to false to hide without deleting
created_at        timestamp   Auto-set on write
```

### Cost Tier Reference

| Tier | Meaning |
|---|---|
| free | No cost to attend |
| paid_low | Under $20/person |
| paid_mid | $20–$60/person |
| paid_high | Over $60/person |

### Audience Tag Reference

| Tag | Meaning |
|---|---|
| family | Adults + children together |
| kids | Child-focused (age 3–12) |
| couples | Adult pairs, romantic or low-key |
| friends | Groups of adults |

### Region Reference

| Tag | Coverage |
|---|---|
| downtown_toronto | City of Toronto core |
| west_gta | Mississauga, Brampton, Oakville, Burlington |
| east_gta | Scarborough, Pickering, Ajax, Whitby |
| north_gta | Vaughan, Richmond Hill, Markham, Newmarket |
| niagara | Niagara Falls, St. Catharines (within 1.5hr drive) |

---

## Sample Event (Worked Example)

```json
{
  "name": "Toronto Waterfront Night Market",
  "description": "A summer evening market along the lakeshore with 80+ food vendors, live music, and family-friendly activities. Best attended after 6 PM when the lights come on.",
  "region": "downtown_toronto",
  "start_date": "2026-07-04T00:00:00Z",
  "end_date": "2026-08-30T00:00:00Z",
  "is_recurring": true,
  "recurrence_note": "Every Friday and Saturday evening, July–August",
  "audience": ["family", "couples", "friends"],
  "cost_tier": "free",
  "cost_note": "Free entry. Food and drinks paid separately.",
  "source_url": "https://www.waterfronttoronto.ca",
  "image_url": "",
  "active": true
}
```

---

## UI Structure (Screens)

### Screen 1 — Home / Calendar View
- Header: App name + current month/week label
- Quick filter bar: [This Weekend] [This Week] [This Month]
- Audience filter chips: [Family] [Kids] [Couples] [Friends]
- Region filter: dropdown or horizontal scroll chips
- Event card list: scrollable, chronological
- Each card: thumbnail (if available), event name, date, region pill, cost tier, audience tags

### Screen 2 — Event Detail
- Full event name
- Date window + recurrence note
- Region + cost note
- Full description
- Audience tags
- "View Source" button → opens source_url in browser
- "Open in Maps" button → opens address in Google Maps

### No other screens in v1.

---

## Design Principles

- Mobile-first. Every element designed for a phone screen, not a tablet.
- Card-based layout. Events are cards, not list rows.
- Filters are always visible. Don't hide them behind a drawer.
- Colour palette: warm and seasonal. Think farmers market, not corporate SaaS.
- Font: clean and readable at small sizes. No decorative fonts.
- Empty state: if no events match filters, show a friendly message + suggestion to widen filters. Never show a blank screen.

---

## Working Style Instructions for Claude Code

- **One concept at a time.** Fully implement and confirm one thing before moving to the next.
- **Explain before you build.** For anything non-obvious, give a one-sentence plain English explanation of what the code does before writing it.
- **Do not add features not in scope.** If a natural extension exists, note it briefly but do not implement it.
- **Prefer simple over clever.** This is a side project maintained by one person. Readability beats elegance.
- **Flutter conventions.** Use StatefulWidget where state is needed. Keep widgets small and composable. Separate data fetching from UI.
- **Firestore reads.** Use real-time listeners (snapshots) for the event list so updates reflect without restart.
- **No hardcoded data.** All event data comes from Firestore. No local JSON fallbacks in v1.

---

## Build Phases (12-Week Plan)

| Phase | Weeks | Focus |
|---|---|---|
| 1 — Setup | 1–2 | Flutter project init, Firebase connection, Firestore rules |
| 2 — Data | 3–4 | Data sheet population (30–50 events), Firestore import |
| 3 — UI Core | 5–7 | Home screen, filters, event cards, detail screen |
| 4 — Polish | 8–9 | Empty states, error handling, loading states, design pass |
| 5 — Beta | 10–11 | Internal testing, fix bugs, Play Store listing prep |
| 6 — Launch | 12 | Play Store submission |

**Current status: Phase 1 — not yet started.**

---

## What Has NOT Been Built Yet

- No Flutter project created
- No Firebase project created
- No Firestore schema implemented
- No Google Sheet populated
- No UI built

Start from zero. The context above is the design spec.
