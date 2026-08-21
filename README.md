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

## 37 games live

Category spread: **Puzzle 16 · Action 11 · Racing 3 · Strategy 5 · Sports 2**

The original 8 (canvas-built, level/wave progression, upgrades) plus 24 ported from an earlier build — see each game's own file for its specific mechanic. All 32 were checked for load-time and gameplay JS errors before shipping (headless jsdom pass, zero errors). Every game has a fixed **✕** exit button (top-right) that routes back to `game.html?id=<slug>` in this platform.

## Advertising — architecture in place, no fake numbers

`js/ads.js` (`AdService`) renders a clearly labeled placeholder banner (`AdService.showBanner`) and a skippable pre-game interstitial (`AdService.showInterstitial`) — used on the homepage, games listing, and right before a game launches from `game.html`. Both work identically whether the page is opened in a browser tab or from an installed PWA, since it's the same web content either way.

Nothing here invents ad revenue or impressions. Once a real ad network (AdMob, IronSource, etc.) is connected, set `AdService.provider` and replace the two placeholder branches in `js/ads.js` with the real SDK calls — every page that calls `AdService.showBanner()`/`showInterstitial()` picks it up automatically, no per-page changes needed. Impression/click events should log to the `ad_events` table in `supabase_schema.sql`.

## Installing as an app (PWA)

Icons are generated at `assets/icons/`. On Android Chrome, visiting the site shows an "Install app" prompt (or Menu → "Add to Home screen"); on iOS Safari, use Share → "Add to Home Screen". Once installed, `service-worker.js` caches the shell pages **and all 8 game files**, so previously-opened games keep working offline. Ads (once connected) still render normally in the installed app, since it's the same served web content — no separate build needed.

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
