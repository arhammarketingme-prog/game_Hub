# GameHub — Phase 1 Launch Build

Instant-play original games platform. Dark, premium, mobile-first. Built as static HTML/CSS/JS so it deploys straight to GitHub Pages, with Supabase as the backend.

## What's live in this build

- **Homepage** (`index.html`) — hero, trending/new/original/category rails
- **Universal game browsing** — `games.html` (filterable grid), `search.html` (instant search), `categories.html`
- **Game info + player launch** — `game.html` (pre-play info page → links straight into the game)
- **3 fully playable original games** (see below)
- **Account shell** — `profile.html`, `library.html` (UI ready, wire to Supabase Auth next)
- **Developer portal** — `developer.html` (registration + submission form UI), `dashboard.html`
- **Admin shell** — `admin.html` (review queue + revenue-share settings UI)
- **PWA** — `manifest.json`, `service-worker.js` (installable, offline app shell)
- **Database** — `supabase_schema.sql` (full schema, RLS policies, seed data for the 3 launch games)

Forms on developer/admin pages are UI-complete but not yet wired to Supabase writes — they show what will happen once auth is connected. This was a deliberate call per the build priority order (play experience first, dashboards after).

## The 3 launch games

| Game | Category | Mechanic |
|---|---|---|
| **Neon Survivor** | Action | Top-down wave survival, auto-fire, level-up upgrade picks, boss waves |
| **Merge Forge** | Puzzle | Grid merge puzzle, tiered items, move-limited levels, star rating |
| **Color Collapse** | Puzzle | Flood-fill color pop, combo scoring, bomb power-up, progressive targets |

Each game has: start screen, pause, restart, game-over/win screens, mobile touch controls, sound (synthesized — no external audio files needed), score/coins, level progression saved to `localStorage`, and a working exit-to-GameHub link.

Add more games by creating `games/<slug>/index.html` and adding a matching entry to `js/catalog-data.js` (or, once Supabase is wired, inserting a row into the `games` table — the homepage/listing pages just need `renderRail`/`renderGrid` fed live data instead of the static array).

## Deploy to GitHub Pages

1. Push this folder to a GitHub repo (root of the repo, or `/docs` if you configure Pages that way).
2. Repo → Settings → Pages → Deploy from branch → select branch/folder.
3. Every page is already named so Pages resolves them directly (`index.html` at root and inside each game folder).
4. Wait ~1 minute, then visit the Pages URL.

## Set up Supabase

1. Create a new Supabase project.
2. SQL Editor → paste the full contents of `supabase_schema.sql` → Run.
3. This creates all core tables, enables Row Level Security with policies, and seeds `categories` + the 3 launch games.
4. Project Settings → API → copy the **Project URL** and **anon public key**.
5. Create `js/supabase-client.js`:
   ```js
   const supabase = window.supabase.createClient(
     "YOUR_PROJECT_URL",
     "YOUR_ANON_KEY"
   );
   ```
   Load the Supabase JS SDK via CDN in each page (`<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>`) before this file.
6. Never put the **service-role key** in frontend code — only the anon key belongs in the browser.
7. Swap `js/catalog-data.js`'s static `GAMEHUB_CATALOG` array for a live query against `games` (`status = 'published'`) once ready.

## Testing checklist (per game, before marking LIVE)

- [ ] Game loads with no console errors
- [ ] Play button actually starts the game
- [ ] Controls respond (touch + mouse/keyboard fallback)
- [ ] Pause / Resume works
- [ ] Restart works mid-game
- [ ] Game-over / win screen displays correctly
- [ ] Mobile layout has no horizontal scroll, safe-area respected
- [ ] Sound toggles correctly (where applicable)
- [ ] Exit link returns to `game.html`/GameHub cleanly
- [ ] Score/progress persists across sessions where intended

## Next milestones (see build spec for full detail)

1. Wire Supabase Auth (register/login/verify/reset) on `profile.html`
2. Wire `wishlists` table into `library.html`
3. Wire developer submission form to insert into `games` (status `submitted`)
4. Build admin approve/reject actions against `games.status`
5. Connect a real ad network — until then, revenue stays labeled "Advertising integration pending," never estimated
6. Grow catalog: next milestone is 10 playable games, then 20–25 for full Phase 1
