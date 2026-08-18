/* GameHub service worker — caches the app shell for offline access.
   Game pages are cached on first visit (runtime cache) so a played
   game can be reopened without network. */
const SHELL_CACHE = 'gamehub-shell-v1';
const RUNTIME_CACHE = 'gamehub-runtime-v1';

const SHELL_FILES = [
  './index.html',
  './games.html',
  './search.html',
  './game.html',
  './categories.html',
  './library.html',
  './profile.html',
  './css/style.css',
  './css/ads.css',
  './js/app.js',
  './js/catalog-data.js',
  './js/ads.js',
  './manifest.json',
  './games/neon-survivor/index.html',
  './games/merge-forge/index.html',
  './games/color-collapse/index.html',
  './games/shadow-dash/index.html',
  './games/nitro-rush/index.html',
  './games/hoop-master/index.html',
  './games/sky-defender/index.html',
  './games/mini-empire/index.html'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(SHELL_CACHE).then((cache) => cache.addAll(SHELL_FILES))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k !== SHELL_CACHE && k !== RUNTIME_CACHE)
          .map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;
      return fetch(request)
        .then((response) => {
          if (response.ok && request.url.startsWith(self.location.origin)) {
            const clone = response.clone();
            caches.open(RUNTIME_CACHE).then((cache) => cache.put(request, clone));
          }
          return response;
        })
        .catch(() => caches.match('./index.html'));
    })
  );
});
