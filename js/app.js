/* ============================================================
   GAMEHUB — shared UI logic (no framework, vanilla JS)
   ============================================================ */

const BADGE_LABEL = { hot: "HOT", new: "NEW", top: "TOP RATED", original: "ORIGINAL" };

function cardHTML(game){
  const badgeClass = `badge-${game.badge}`;
  const badgeText = BADGE_LABEL[game.badge] || "";
  return `
  <a class="card" href="game.html?id=${game.id}" data-id="${game.id}">
    <div class="card-art" style="background:${game.accent}">
      ${badgeText ? `<span class="card-badge ${badgeClass}">${badgeText}</span>` : ""}
      <span>${game.icon}</span>
    </div>
    <div class="card-body">
      <div class="card-name">${game.name}</div>
      <div class="card-meta">
        <span class="stars">★ ${game.rating}</span>
        <span>${game.plays} plays</span>
      </div>
    </div>
  </a>`;
}

function renderRail(containerId, games){
  const el = document.getElementById(containerId);
  if(!el) return;
  if(!games.length){
    el.innerHTML = `<div class="empty-state">
        <div class="display">More games loading soon</div>
        <div>New original titles ship every week.</div>
      </div>`;
    return;
  }
  el.innerHTML = games.map(cardHTML).join("");
}

function renderGrid(containerId, games){
  const el = document.getElementById(containerId);
  if(!el) return;
  el.className = "grid-cards";
  if(!games.length){
    el.innerHTML = `<div class="empty-state" style="grid-column:1/-1">
        <div class="display">No games here yet</div>
        <div>Try another category or check back soon.</div>
      </div>`;
    return;
  }
  el.innerHTML = games.map(cardHTML).join("");
}

function renderBottomNav(active){
  const items = [
    { id:"home", label:"Home", href:"index.html", icon:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/></svg>` },
    { id:"games", label:"Games", href:"games.html", icon:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="7" width="18" height="12" rx="3"/><path d="M8 11v4M6 13h4M15 12h.01M17.5 14.5h.01"/></svg>` },
    { id:"search", label:"Search", href:"search.html", icon:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>` },
    { id:"library", label:"Library", href:"library.html", icon:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18"/></svg>` },
    { id:"profile", label:"Profile", href:"profile.html", icon:`<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="4"/><path d="M4 21c1.5-4 5-6 8-6s6.5 2 8 6"/></svg>` }
  ];
  const el = document.getElementById("bottom-nav");
  if(!el) return;
  el.innerHTML = items.map(it => `
    <a class="nav-item ${it.id===active?'active':''}" href="${it.href}">
      ${it.icon}
      <span>${it.label}</span>
    </a>`).join("");
}

function getQueryParam(name){
  return new URLSearchParams(window.location.search).get(name);
}

function findGame(id){
  return GAMEHUB_CATALOG.find(g => g.id === id);
}
