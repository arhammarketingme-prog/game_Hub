/* ============================================================
   LAUNCH CATALOG — Phase 1
   Only games that are ACTUALLY playable are listed here.
   Per build rule: never render a card that opens an empty page.
   As new games ship, add their metadata objects here (or, once
   Supabase is wired, this file is replaced by a live query to
   the `games` table — see supabase_schema.sql).
   ============================================================ */

const GAMEHUB_CATALOG = [
  {
    id: "merge-forge",
    name: "Merge Forge",
    tagline: "Merge, upgrade, unleash the forge.",
    category: "puzzle",
    categoryLabel: "Puzzle",
    developer: "GameHub Studio",
    badge: "new",
    rating: 4.7,
    plays: "2.1k",
    icon: "🔨",
    accent: "linear-gradient(135deg,#3a2a6b,#151022)",
    path: "games/merge-forge/index.html",
    original: true
  },
  {
    id: "color-collapse",
    name: "Color Collapse",
    tagline: "Chain colors before the grid overflows.",
    category: "puzzle",
    categoryLabel: "Puzzle",
    developer: "GameHub Studio",
    badge: "hot",
    rating: 4.6,
    plays: "3.4k",
    icon: "🟣",
    accent: "linear-gradient(135deg,#1b3a5c,#0d1420)",
    path: "games/color-collapse/index.html",
    original: true
  },
  {
    id: "neon-survivor",
    name: "Neon Survivor",
    tagline: "Outlast the swarm. Upgrade or die.",
    category: "action",
    categoryLabel: "Action",
    developer: "GameHub Studio",
    badge: "top",
    rating: 4.8,
    plays: "5.0k",
    icon: "⚡",
    accent: "linear-gradient(135deg,#4a1042,#12081a)",
    path: "games/neon-survivor/index.html",
    original: true
  }
];

const GAMEHUB_CATEGORIES = [
  { id: "all", label: "All" },
  { id: "puzzle", label: "🧩 Puzzle" },
  { id: "action", label: "⚔️ Action" },
  { id: "racing", label: "🏎️ Racing" },
  { id: "sports", label: "🏆 Sports" },
  { id: "strategy", label: "🏰 Strategy" }
];
