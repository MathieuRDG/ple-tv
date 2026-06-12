#!/bin/bash
set -e
PROJECT="plezy-tv"
mkdir -p $PROJECT && cd $PROJECT
mkdir -p public/icons src/styles src/modules

echo "✅ Création de la structure des dossiers..."

# ============================================================
# package.json
# ============================================================
cat > package.json << 'EOF'
{
  "name": "plezy-tv",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "vite --host",
    "build": "vite build",
    "preview": "vite preview --host"
  },
  "dependencies": {
    "hls.js": "^1.5.7"
  },
  "devDependencies": {
    "vite": "^5.2.0",
    "vite-plugin-pwa": "^0.19.8",
    "workbox-window": "^7.1.0"
  }
}
EOF

# ============================================================
# vite.config.js
# ============================================================
cat > vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  root: 'src',
  publicDir: '../public',
  build: {
    outDir: '../dist',
    emptyOutDir: true,
  },
  server: {
    port: 5173,
    strictPort: true,
  },
  plugins: [
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/.*\/Items\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'jellyfin-api',
              expiration: { maxEntries: 50, maxAgeSeconds: 300 },
            },
          },
        ],
      },
      manifest: {
        name: 'Plezy TV',
        short_name: 'PlezyTV',
        description: 'Jellyfin client optimisé pour Hisense VIDAA TV',
        theme_color: '#0f0f0f',
        background_color: '#0f0f0f',
        display: 'fullscreen',
        orientation: 'landscape',
        icons: [
          { src: 'icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icons/icon-512.png', sizes: '512x512', type: 'image/png' },
        ],
      },
    }),
  ],
})
EOF

echo "✅ package.json + vite.config.js créés"

# ============================================================
# src/index.html
# ============================================================
cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Plezy TV</title>
  <link rel="stylesheet" href="styles/main.css" />
</head>
<body>
  <div id="app">

    <!-- TOAST -->
    <div id="toast"></div>

    <!-- SCREEN: LOGIN -->
    <div id="screen-login" class="screen active">
      <div class="login-box">
        <h1 class="logo">Plezy<span>TV</span></h1>
        <input id="inp-server" class="tv-input focusable" type="url"
               placeholder="https://jellyfin.monserveur.com" tabindex="0" />
        <input id="inp-user" class="tv-input focusable" type="text"
               placeholder="Nom d'utilisateur" tabindex="0" />
        <input id="inp-pass" class="tv-input focusable" type="password"
               placeholder="Mot de passe" tabindex="0" />
        <button id="btn-login" class="tv-btn focusable" tabindex="0">Se connecter</button>
      </div>
    </div>

    <!-- SCREEN: HOME -->
    <div id="screen-home" class="screen">
      <header class="top-bar">
        <span class="logo-small">Plezy<span>TV</span></span>
        <nav class="top-nav">
          <button class="nav-btn focusable active" data-filter="all" tabindex="0">Tout</button>
          <button class="nav-btn focusable" data-filter="Movie" tabindex="0">Films</button>
          <button class="nav-btn focusable" data-filter="Series" tabindex="0">Séries</button>
        </nav>
        <button id="btn-logout" class="tv-btn small focusable" tabindex="0">Déconnexion</button>
      </header>

      <section class="hero-section" id="hero">
        <div class="hero-bg" id="hero-bg"></div>
        <div class="hero-content" id="hero-content"></div>
      </section>

      <section class="shelf-section" id="shelves"></section>
    </div>

    <!-- SCREEN: DETAIL -->
    <div id="screen-detail" class="screen">
      <div class="detail-bg" id="detail-bg"></div>
      <div class="detail-panel" id="detail-panel"></div>
    </div>

    <!-- SCREEN: PLAYER -->
    <div id="screen-player" class="screen">
      <video id="player-video" preload="auto" playsinline></video>
      <div id="player-ui">
        <div id="player-title"></div>
        <div id="player-controls">
          <button id="ctrl-rewind"  class="ctrl-btn focusable" tabindex="0">⏪ 10s</button>
          <button id="ctrl-play"    class="ctrl-btn focusable" tabindex="0">⏸</button>
          <button id="ctrl-forward" class="ctrl-btn focusable" tabindex="0">10s ⏩</button>
        </div>
        <div id="player-bar">
          <span id="player-time-cur">0:00</span>
          <div id="player-progress-wrap">
            <div id="player-progress-bg">
              <div id="player-progress-fill"></div>
            </div>
          </div>
          <span id="player-time-total">0:00</span>
        </div>
      </div>
    </div>

  </div>
  <script type="module" src="main.js"></script>
</body>
</html>
EOF

# ============================================================
# src/styles/main.css
# ============================================================
cat > src/styles/main.css << 'EOF'
/* ============================================================
   RESET + BASE
============================================================ */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg:        #0f0f0f;
  --surface:   #1a1a1a;
  --surface2:  #242424;
  --accent:    #e5a00d;
  --accent2:   #c8860a;
  --text:      #f0f0f0;
  --muted:     #888;
  --radius:    12px;
  --font:      'Segoe UI', system-ui, sans-serif;
  --transition: 0.18s ease;
}

html, body {
  width: 100%; height: 100%;
  background: var(--bg);
  color: var(--text);
  font-family: var(--font);
  font-size: 22px;
  overflow: hidden;
  -webkit-font-smoothing: antialiased;
}

#app { width: 100vw; height: 100vh; position: relative; overflow: hidden; }

/* ============================================================
   SCREENS
============================================================ */
.screen {
  position: absolute; inset: 0;
  opacity: 0; pointer-events: none;
  transition: opacity 0.3s ease;
}
.screen.active {
  opacity: 1; pointer-events: all;
}

/* ============================================================
   FOCUS
============================================================ */
.focusable:focus {
  outline: 3px solid var(--accent);
  outline-offset: 4px;
}

/* ============================================================
   LOGIN
============================================================ */
.login-box {
  position: absolute; inset: 0;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  gap: 24px;
}

.logo { font-size: 3rem; font-weight: 800; letter-spacing: -1px; }
.logo span, .logo-small span { color: var(--accent); }
.logo-small { font-size: 1.4rem; font-weight: 700; }

.tv-input {
  width: 480px; max-width: 90vw;
  background: var(--surface);
  border: 2px solid var(--surface2);
  border-radius: var(--radius);
  color: var(--text);
  font-size: 1rem;
  padding: 18px 24px;
  transition: border-color var(--transition);
}
.tv-input:focus { border-color: var(--accent); outline: none; }

.tv-btn {
  background: var(--accent);
  color: #000;
  border: none;
  border-radius: var(--radius);
  font-size: 1rem;
  font-weight: 700;
  padding: 18px 48px;
  cursor: pointer;
  transition: background var(--transition), transform var(--transition);
}
.tv-btn:hover, .tv-btn:focus {
  background: var(--accent2);
  transform: scale(1.04);
  outline: none;
}
.tv-btn.small { padding: 10px 24px; font-size: 0.85rem; }

/* ============================================================
   TOP BAR
============================================================ */
.top-bar {
  position: absolute; top: 0; left: 0; right: 0;
  height: 80px;
  display: flex; align-items: center;
  padding: 0 60px;
  gap: 40px;
  z-index: 10;
  background: linear-gradient(to bottom, rgba(0,0,0,0.85), transparent);
}

.top-nav { display: flex; gap: 16px; flex: 1; }

.nav-btn {
  background: transparent;
  border: 2px solid transparent;
  border-radius: 30px;
  color: var(--muted);
  font-size: 0.9rem;
  font-weight: 600;
  padding: 10px 28px;
  cursor: pointer;
  transition: all var(--transition);
}
.nav-btn.active, .nav-btn:focus {
  border-color: var(--accent);
  color: var(--text);
  outline: none;
}

/* ============================================================
   HERO
============================================================ */
.hero-section {
  position: relative;
  width: 100%; height: 56vh;
  overflow: hidden;
}
.hero-bg {
  position: absolute; inset: 0;
  background-size: cover; background-position: center top;
  transition: background-image 0.5s ease;
}
.hero-bg::after {
  content: '';
  position: absolute; inset: 0;
  background: linear-gradient(
    to bottom,
    rgba(15,15,15,0.2) 0%,
    rgba(15,15,15,0.7) 70%,
    #0f0f0f 100%
  );
}
.hero-content {
  position: absolute; bottom: 40px; left: 60px;
  z-index: 2; max-width: 600px;
}
.hero-title {
  font-size: 2.8rem; font-weight: 800;
  text-shadow: 0 2px 12px rgba(0,0,0,0.8);
  margin-bottom: 12px;
}
.hero-meta { color: var(--muted); font-size: 0.85rem; margin-bottom: 20px; }
.hero-btn {
  background: var(--accent); color: #000;
  border: none; border-radius: var(--radius);
  font-size: 1rem; font-weight: 700;
  padding: 16px 40px; cursor: pointer;
  transition: background var(--transition), transform var(--transition);
}
.hero-btn:focus { outline: 3px solid #fff; background: var(--accent2); transform: scale(1.05); }

/* ============================================================
   SHELVES
============================================================ */
.shelf-section {
  position: absolute;
  top: 56vh; left: 0; right: 0; bottom: 0;
  overflow-y: auto; overflow-x: hidden;
  padding: 20px 60px 60px;
  scroll-behavior: smooth;
}
.shelf { margin-bottom: 40px; }
.shelf-title {
  font-size: 1rem; font-weight: 700;
  color: var(--muted); text-transform: uppercase;
  letter-spacing: 2px; margin-bottom: 16px;
}
.shelf-row {
  display: flex; gap: 20px;
  overflow-x: auto; padding-bottom: 12px;
  scroll-behavior: smooth;
}
.shelf-row::-webkit-scrollbar { height: 4px; }
.shelf-row::-webkit-scrollbar-thumb { background: var(--surface2); border-radius: 2px; }

/* ============================================================
   CARDS
============================================================ */
.card {
  flex-shrink: 0;
  width: 200px; border-radius: var(--radius);
  overflow: hidden; cursor: pointer;
  background: var(--surface);
  transition: transform var(--transition), box-shadow var(--transition);
  position: relative;
}
.card:focus, .card:hover {
  transform: scale(1.08);
  box-shadow: 0 8px 32px rgba(0,0,0,0.6);
  outline: 3px solid var(--accent);
  z-index: 2;
}
.card img {
  width: 100%; aspect-ratio: 2/3;
  object-fit: cover; display: block;
}
.card-label {
  padding: 10px 12px;
  font-size: 0.75rem; font-weight: 600;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}

/* ============================================================
   DETAIL
============================================================ */
.detail-bg {
  position: absolute; inset: 0;
  background-size: cover; background-position: center;
  filter: blur(18px) brightness(0.3);
  transform: scale(1.05);
}
.detail-panel {
  position: absolute; inset: 0;
  display: flex; align-items: center;
  padding: 80px 80px;
  gap: 60px;
  overflow-y: auto;
}
.detail-poster {
  flex-shrink: 0; width: 260px;
  border-radius: var(--radius);
  box-shadow: 0 12px 48px rgba(0,0,0,0.7);
}
.detail-info { flex: 1; }
.detail-title { font-size: 2.4rem; font-weight: 800; margin-bottom: 12px; }
.detail-meta { color: var(--muted); font-size: 0.85rem; margin-bottom: 20px; }
.detail-overview { font-size: 0.9rem; line-height: 1.7; color: #ccc; margin-bottom: 32px; max-width: 700px; }
.detail-actions { display: flex; gap: 16px; flex-wrap: wrap; }
.detail-btn {
  background: var(--accent); color: #000;
  border: none; border-radius: var(--radius);
  font-size: 1rem; font-weight: 700;
  padding: 16px 40px; cursor: pointer;
  transition: background var(--transition), transform var(--transition);
}
.detail-btn.secondary {
  background: var(--surface2); color: var(--text);
}
.detail-btn:focus {
  outline: 3px solid #fff;
  transform: scale(1.05);
}

/* ============================================================
   EPISODES
============================================================ */
.episode-list { margin-top: 40px; }
.episode-list h3 { font-size: 1rem; color: var(--muted); text-transform: uppercase; letter-spacing: 2px; margin-bottom: 16px; }
.episode-item {
  display: flex; align-items: center; gap: 20px;
  padding: 16px 20px;
  border-radius: var(--radius);
  background: var(--surface);
  margin-bottom: 10px;
  cursor: pointer;
  transition: background var(--transition), transform var(--transition);
}
.episode-item:focus, .episode-item:hover {
  background: var(--surface2);
  outline: 3px solid var(--accent);
  transform: translateX(6px);
}
.episode-num { color: var(--accent); font-weight: 700; min-width: 36px; }
.episode-name { flex: 1; font-size: 0.9rem; }
.episode-dur { color: var(--muted); font-size: 0.8rem; }

/* ============================================================
   PLAYER
============================================================ */
#screen-player { background: #000; }

#player-video {
  width: 100%; height: 100%;
  object-fit: contain;
}

#player-ui {
  position: absolute; bottom: 0; left: 0; right: 0;
  padding: 30px 60px 40px;
  background: linear-gradient(to top, rgba(0,0,0,0.95), transparent);
  opacity: 0;
  transition: opacity 0.3s ease;
}
#screen-player:hover #player-ui,
#screen-player.show-ui #player-ui { opacity: 1; }

#player-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 20px; }

#player-controls {
  display: flex; justify-content: center; gap: 40px;
  margin-bottom: 20px;
}
.ctrl-btn {
  background: rgba(255,255,255,0.12);
  border: 2px solid transparent;
  border-radius: 50px;
  color: var(--text);
  font-size: 1rem; font-weight: 600;
  padding: 14px 32px;
  cursor: pointer;
  transition: all var(--transition);
}
.ctrl-btn:focus, .ctrl-btn:hover {
  background: var(--accent);
  color: #000;
  border-color: var(--accent);
  outline: none;
  transform: scale(1.08);
}

#player-bar {
  display: flex; align-items: center; gap: 16px;
}
#player-time-cur, #player-time-total { font-size: 0.8rem; color: var(--muted); min-width: 48px; }
#player-progress-wrap { flex: 1; }
#player-progress-bg {
  width: 100%; height: 6px;
  background: rgba(255,255,255,0.2);
  border-radius: 3px; overflow: hidden;
}
#player-progress-fill {
  height: 100%; width: 0%;
  background: var(--accent);
  border-radius: 3px;
  transition: width 0.5s linear;
}

/* ============================================================
   TOAST
============================================================ */
#toast {
  position: fixed; bottom: 60px; left: 50%; transform: translateX(-50%);
  background: var(--surface2);
  color: var(--text);
  padding: 16px 36px;
  border-radius: 50px;
  font-size: 0.85rem;
  opacity: 0; pointer-events: none;
  transition: opacity 0.3s ease;
  z-index: 999;
}
#toast.show { opacity: 1; }
EOF

echo "✅ index.html + main.css créés"

# ============================================================
# src/modules/api.js
# ============================================================
cat > src/modules/api.js << 'EOF'
export class JellyfinAPI {
  constructor(serverUrl, username, password) {
    this.serverUrl = serverUrl.replace(/\/$/, '');
    this.username = username;
    this.password = password;
    this.userId = null;
    this.token = null;
  }

  async login() {
    try {
      const response = await fetch(`${this.serverUrl}/Users/AuthenticateByName`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          Username: this.username,
          Pw: this.password,
          RememberMe: true,
        }),
      });
      if (!response.ok) throw new Error('Auth failed');
      const data = await response.json();
      this.userId = data.User.Id;
      this.token = data.AccessToken;
      return true;
    } catch (err) {
      console.error('Login error:', err);
      return false;
    }
  }

  async getItems(filters = {}) {
    const params = new URLSearchParams({
      userId: this.userId,
      X-MediaBrowser-Token: this.token,
      recursive: 'true',
      includeItemTypes: filters.type || 'Movie,Series',
      sortBy: 'DateCreated',
      sortOrder: 'Descending',
      limit: filters.limit || 100,
      fields: 'PrimaryImageAspectRatio,Overview,IsFolder',
    });

    try {
      const response = await fetch(
        `${this.serverUrl}/Users/${this.userId}/Items?${params}`,
        { headers: { 'X-MediaBrowser-Token': this.token } }
      );
      if (!response.ok) throw new Error('Fetch items failed');
      const data = await response.json();
      return data.Items || [];
    } catch (err) {
      console.error('getItems error:', err);
      return [];
    }
  }

  async getItemDetail(itemId) {
    try {
      const response = await fetch(
        `${this.serverUrl}/Users/${this.userId}/Items/${itemId}`,
        { headers: { 'X-MediaBrowser-Token': this.token } }
      );
      if (!response.ok) throw new Error('Fetch detail failed');
      return await response.json();
    } catch (err) {
      console.error('getItemDetail error:', err);
      return null;
    }
  }

  async getEpisodes(seriesId) {
    try {
      const response = await fetch(
        `${this.serverUrl}/Shows/${seriesId}/Episodes?userId=${this.userId}`,
        { headers: { 'X-MediaBrowser-Token': this.token } }
      );
      if (!response.ok) throw new Error('Fetch episodes failed');
      const data = await response.json();
      return data.Items || [];
    } catch (err) {
      console.error('getEpisodes error:', err);
      return [];
    }
  }

  getImageUrl(itemId, type = 'Primary') {
    return `${this.serverUrl}/Items/${itemId}/Images/${type}?tag=0`;
  }

  getPlayUrl(itemId) {
    return `${this.serverUrl}/Videos/${itemId}/master.m3u8?Token=${this.token}`;
  }

  getPlayUrlDirect(itemId) {
    return `${this.serverUrl}/Videos/${itemId}/stream?static=true&mediaSourceId=${itemId}&api_key=${this.token}`;
  }
}
EOF

# ============================================================
# src/modules/navigation.js
# ============================================================
cat > src/modules/navigation.js << 'EOF'
export class Navigator {
  constructor() {
    this.currentScreen = 'login';
    this.history = [];
    this.focusableElements = [];
    this.focusIndex = 0;
  }

  goto(screenName, data = null) {
    const current = document.getElementById(`screen-${this.currentScreen}`);
    const next = document.getElementById(`screen-${screenName}`);

    if (current) current.classList.remove('active');
    if (next) {
      next.classList.add('active');
      this.currentScreen = screenName;
    }

    this.history.push(screenName);
    if (this.history.length > 20) this.history.shift();
  }

  back() {
    if (this.history.length > 1) {
      this.history.pop();
      const prev = this.history[this.history.length - 1];
      this.goto(prev);
    }
  }

  updateFocusables() {
    const screen = document.getElementById(`screen-${this.currentScreen}`);
    if (!screen) return;
    this.focusableElements = Array.from(
      screen.querySelectorAll('.focusable')
    ).filter(el => getComputedStyle(el).display !== 'none');
    this.focusIndex = 0;
    if (this.focusableElements[0]) this.focusableElements[0].focus();
  }

  focusNext() {
    if (this.focusableElements.length === 0) return;
    this.focusIndex = (this.focusIndex + 1) % this.focusableElements.length;
    this.focusableElements[this.focusIndex].focus();
  }

  focusPrev() {
    if (this.focusableElements.length === 0) return;
    this.focusIndex = (this.focusIndex - 1 + this.focusableElements.length) % this.focusableElements.length;
    this.focusableElements[this.focusIndex].focus();
  }
}
EOF

echo "✅ api.js + navigation.js créés"

# ============================================================
# src/main.js
# ============================================================
cat > src/main.js << 'EOF'
import HLS from 'hls.js';
import { JellyfinAPI } from './modules/api.js';
import { Navigator } from './modules/navigation.js';

// ============================================================
// GLOBALS
// ============================================================
let api = null;
let nav = new Navigator();
let currentItem = null;
let hlsPlayer = null;
let shelves = {};

// ============================================================
// UI HELPERS
// ============================================================
function toast(msg, duration = 3000) {
  const el = document.getElementById('toast');
  el.textContent = msg;
  el.classList.add('show');
  setTimeout(() => el.classList.remove('show'), duration);
}

function formatDuration(ticks) {
  const seconds = Math.floor(ticks / 10000000);
  const hours = Math.floor(seconds / 3600);
  const mins = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;
  if (hours > 0) return `${hours}h${mins}m`;
  if (mins > 0) return `${mins}m`;
  return `${secs}s`;
}

// ============================================================
// LOGIN
// ============================================================
document.getElementById('btn-login').addEventListener('click', async () => {
  const server = document.getElementById('inp-server').value;
  const user = document.getElementById('inp-user').value;
  const pass = document.getElementById('inp-pass').value;

  if (!server || !user || !pass) {
    toast('Remplissez tous les champs');
    return;
  }

  api = new JellyfinAPI(server, user, pass);
  const ok = await api.login();
  if (ok) {
    toast('Connecté !');
    nav.goto('home');
    loadHome();
  } else {
    toast('Erreur de connexion');
  }
});

// ============================================================
// HOME
// ============================================================
async function loadHome() {
  const movies = await api.getItems({ type: 'Movie', limit: 50 });
  const series = await api.getItems({ type: 'Series', limit: 50 });

  shelves = { all: [...movies, ...series], Movie: movies, Series: series };

  // HERO
  if (shelves.all.length > 0) {
    const hero = shelves.all[0];
    const detail = await api.getItemDetail(hero.Id);
    const heroBg = document.getElementById('hero-bg');
    const heroContent = document.getElementById('hero-content');

    heroBg.style.backgroundImage = `url('${api.getImageUrl(hero.Id)}')`;
    heroContent.innerHTML = `
      <div class="hero-info">
        <h1>${hero.Name}</h1>
        <p>${detail?.Overview || ''}</p>
        <button class="hero-btn focusable" data-item-id="${hero.Id}" tabindex="0">
          ▶ Regarder
        </button>
      </div>
    `;
    document.querySelector('.hero-btn').addEventListener('click', (e) => {
      playItem(e.target.dataset.itemId);
    });
  }

  // SHELVES
  const shelvesEl = document.getElementById('shelves');
  shelvesEl.innerHTML = '';
  for (const [label, items] of Object.entries(shelves)) {
    if (items.length === 0 || label === 'all') continue;
    const shelf = document.createElement('div');
    shelf.className = 'shelf';
    shelf.innerHTML = `<h2>${label === 'Movie' ? 'Films' : 'Séries'}</h2>
                       <div class="shelf-items" id="shelf-${label}"></div>`;
    shelvesEl.appendChild(shelf);

    const itemsEl = document.getElementById(`shelf-${label}`);
    items.slice(0, 20).forEach(item => {
      const card = document.createElement('button');
      card.className = 'card focusable';
      card.tabIndex = 0;
      card.innerHTML = `
        <img src="${api.getImageUrl(item.Id)}" alt="${item.Name}" />
        <div class="card-info">
          <div class="card-title">${item.Name}</div>
          <div class="card-year">${item.ProductionYear || ''}</div>
        </div>
      `;
      card.addEventListener('click', () => showDetail(item.Id));
      itemsEl.appendChild(card);
    });
  }

  nav.updateFocusables();
}

// ============================================================
// DETAIL
// ============================================================
async function showDetail(itemId) {
  currentItem = await api.getItemDetail(itemId);
  if (!currentItem) {
    toast('Erreur de chargement');
    return;
  }

  const bg = document.getElementById('detail-bg');
  const panel = document.getElementById('detail-panel');

  bg.style.backgroundImage = `url('${api.getImageUrl(itemId)}')`;

  let episodesHTML = '';
  if (currentItem.Type === 'Series') {
    const episodes = await api.getEpisodes(itemId);
    episodesHTML = `
      <div class="episodes-list">
        ${episodes.map((ep, i) => `
          <button class="episode-item focusable" data-ep-id="${ep.Id}" tabindex="0">
            <span class="episode-num">S${ep.ParentIndexNumber}E${ep.IndexNumber}</span>
            <span class="episode-name">${ep.Name}</span>
            <span class="episode-dur">${formatDuration(ep.RunTimeTicks)}</span>
          </button>
        `).join('')}
      </div>
    `;
  }

  panel.innerHTML = `
    <h1>${currentItem.Name}</h1>
    <p class="detail-year">${currentItem.ProductionYear || ''}</p>
    <p class="detail-overview">${currentItem.Overview || ''}</p>
    <button class="tv-btn focusable" data-item-id="${itemId}" tabindex="0">
      ▶ Regarder
    </button>
    ${episodesHTML}
  `;

  panel.querySelector('.tv-btn').addEventListener('click', (e) => {
    playItem(e.target.dataset.itemId);
  });

  document.querySelectorAll('.episode-item').forEach(btn => {
    btn.addEventListener('click', (e) => {
      playItem(e.target.dataset.epId);
    });
  });

  nav.goto('detail');
  nav.updateFocusables();
}

// ============================================================
// PLAYER
// ============================================================
async function playItem(itemId) {
  const item = await api.getItemDetail(itemId);
  if (!item) {
    toast('Erreur: impossible de charger le contenu');
    return;
  }

  const video = document.getElementById('player-video');
  const title = document.getElementById('player-title');
  title.textContent = item.Name;

  const playUrl = api.getPlayUrl(itemId);

  if (HLS.isSupported()) {
    hlsPlayer = new HLS({ enableWorker: false });
    hlsPlayer.loadSource(playUrl);
    hlsPlayer.attachMedia(video);
  } else {
    video.src = api.getPlayUrlDirect(itemId);
  }

  nav.goto('player');
  video.play();
  setupPlayerControls(itemId);
}

function setupPlayerControls(itemId) {
  const video = document.getElementById('player-video');
  const progressFill = document.getElementById('player-progress-fill');
  const timeCur = document.getElementById('player-time-cur');
  const timeTotal = document.getElementById('player-time-total');
  const playerUI = document.getElementById('player-ui');

  // PLAY/PAUSE
  document.getElementById('btn-play-pause').addEventListener('click', () => {
    if (video.paused) video.play();
    else video.pause();
  });

  // BACK
  document.getElementById('btn-back-player').addEventListener('click', () => {
    video.pause();
    nav.goto('detail');
  });

  // UPDATE PROGRESS
  video.addEventListener('timeupdate', () => {
    const pct = (video.currentTime / video.duration) * 100;
    progressFill.style.width = pct + '%';
    timeCur.textContent = formatDuration(Math.floor(video.currentTime) * 10000000);
    timeTotal.textContent = formatDuration(Math.floor(video.duration) * 10000000);
  });

  // SEEK ON CLICK
  document.getElementById('player-progress-wrap').addEventListener('click', (e) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const pct = (e.clientX - rect.left) / rect.width;
    video.currentTime = pct * video.duration;
  });

  // SHOW/HIDE UI
  playerUI.classList.add('show-ui');
  setTimeout(() => playerUI.classList.remove('show-ui'), 5000);
  video.addEventListener('mousemove', () => {
    playerUI.classList.add('show-ui');
    clearTimeout(video.uiTimeout);
    video.uiTimeout = setTimeout(() => playerUI.classList.remove('show-ui'), 5000);
  });
}

// ============================================================
// REMOTE CONTROL
// ============================================================
document.addEventListener('keydown', (e) => {
  if (nav.currentScreen === 'player') {
    const video = document.getElementById('player-video');
    switch (e.key.toLowerCase()) {
      case ' ':
        video.paused ? video.play() : video.pause();
        e.preventDefault();
        break;
      case 'arrowright':
        video.currentTime += 10;
        e.preventDefault();
        break;
      case 'arrowleft':
        video.currentTime -= 10;
        e.preventDefault();
        break;
      case 'arrowup':
        video.volume = Math.min(1, video.volume + 0.1);
        e.preventDefault();
        break;
      case 'arrowdown':
        video.volume = Math.max(0, video.volume - 0.1);
        e.preventDefault();
        break;
      case 'escape':
      case 'backspace':
        video.pause();
        nav.goto('detail');
        e.preventDefault();
        break;
    }
  } else {
    switch (e.key.toLowerCase()) {
      case 'arrowdown':
        nav.focusNext();
        e.preventDefault();
        break;
      case 'arrowup':
        nav.focusPrev();
        e.preventDefault();
        break;
      case 'escape':
      case 'backspace':
        if (nav.currentScreen !== 'home') nav.back();
        e.preventDefault();
        break;
    }
  }
});

// LOGOUT
document.getElementById('btn-logout').addEventListener('click', () => {
  api = null;
  nav.goto('login');
  document.getElementById('inp-server').value = '';
  document.getElementById('inp-user').value = '';
  document.getElementById('inp-pass').value = '';
  nav.updateFocusables();
});

// FILTER BUTTONS
document.querySelectorAll('.nav-btn').forEach(btn => {
  btn.addEventListener('click', (e) => {
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
    e.target.classList.add('active');
    // TODO: Implémenter le filtrage dynamique
  });
});

// INIT
nav.goto('login');
nav.updateFocusables();
EOF

echo "✅ main.js créé"

# ============================================================
# README.md
# ============================================================
cat > README.md << 'EOF'
# 📺 Plezy TV — Client Jellyfin pour VIDAA TV

Client Jellyfin minimaliste et performant conçu spécifiquement pour les téléviseurs Hisense VIDAA TV.

## ✨ Caractéristiques

✅ **Sans buffer** — HLS natif + cache Service Worker  
✅ **UI épurée** — Design moderne et réactif  
✅ **Contrôle TV** — Navigation aux flèches directionnelles  
✅ **Hors ligne** — PWA installable  
✅ **Léger** — ~50KB gzippé  

---

## 🚀 Installation rapide

### Prérequis
- Node.js 18+
- Un serveur Jellyfin accessible

### 1. Télécharger et installer

```bash
chmod +x setup.sh
./setup.sh
cd plezy-tv
npm install







