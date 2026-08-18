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
  },
  {
    id: "shadow-dash",
    name: "Shadow Dash",
    tagline: "Switch lanes. Dash through danger.",
    category: "action",
    categoryLabel: "Action",
    developer: "GameHub Studio",
    badge: "new",
    rating: 4.5,
    plays: "1.2k",
    icon: "💨",
    accent: "linear-gradient(135deg,#241a3d,#0d0a17)",
    path: "games/shadow-dash/index.html",
    original: true
  },
  {
    id: "nitro-rush",
    name: "Nitro Rush",
    tagline: "Dodge traffic. Bank nitro. Go faster.",
    category: "racing",
    categoryLabel: "Racing",
    developer: "GameHub Studio",
    badge: "hot",
    rating: 4.6,
    plays: "1.8k",
    icon: "🏎️",
    accent: "linear-gradient(135deg,#0f2a3d,#0a0e14)",
    path: "games/nitro-rush/index.html",
    original: true
  },
  {
    id: "hoop-master",
    name: "Hoop Master",
    tagline: "Pull back, release, swish. Chain combos.",
    category: "sports",
    categoryLabel: "Sports",
    developer: "GameHub Studio",
    badge: "new",
    rating: 4.7,
    plays: "980",
    icon: "🏀",
    accent: "linear-gradient(135deg,#3d2a10,#12100a)",
    path: "games/hoop-master/index.html",
    original: true
  },
  {
    id: "sky-defender",
    name: "Sky Defender",
    tagline: "Vertical shooter. Waves, formations, boss fights.",
    category: "action",
    categoryLabel: "Action",
    developer: "GameHub Studio",
    badge: "new",
    rating: 4.6,
    plays: "870",
    icon: "🚀",
    accent: "linear-gradient(135deg,#0d1826,#070c14)",
    path: "games/sky-defender/index.html",
    original: true
  },
  {
    id: "mini-empire",
    name: "Mini Empire",
    tagline: "Build, upgrade, collect. Expand your territory.",
    category: "strategy",
    categoryLabel: "Strategy",
    developer: "GameHub Studio",
    badge: "new",
    rating: 4.5,
    plays: "640",
    icon: "🏰",
    accent: "linear-gradient(135deg,#1c2412,#0d0f0a)",
    path: "games/mini-empire/index.html",
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
