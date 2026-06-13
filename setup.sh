# Plezy-TV pour Hisense 43A6K / VidaaOS

Voici le fichier `setup.sh` complet et fonctionnel :

```bash
#!/bin/bash

# ============================================================
#  PLEZY-TV - Setup Script
#  Hisense 43A6K / VidaaOS / Proxmox LXC
#  Usage: bash setup.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_DIR="/var/www/plezy-tv"
NGINX_CONF="/etc/nginx/sites-available/plezy-tv"
NGINX_ENABLED="/etc/nginx/sites-enabled/plezy-tv"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║           PLEZY-TV INSTALLER             ║"
echo "║     Hisense 43A6K / VidaaOS Ready        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ── 1. SYSTEM UPDATE ────────────────────────────────────────
echo -e "${YELLOW}[1/5] Mise à jour du système...${NC}"
apt-get update -qq
apt-get install -y -qq nginx curl

# ── 2. DIRECTORIES ──────────────────────────────────────────
echo -e "${YELLOW}[2/5] Création des répertoires...${NC}"
mkdir -p "$APP_DIR"

# ── 3. NGINX CONFIG ─────────────────────────────────────────
echo -e "${YELLOW}[3/5] Configuration Nginx...${NC}"

cat > "$NGINX_CONF" << 'NGINXEOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/plezy-tv;
    index index.html;
    server_name _;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header Access-Control-Allow-Origin "*";
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
    add_header Access-Control-Allow-Headers "Content-Type, Authorization";

    gzip on;
    gzip_types text/html text/css application/javascript application/json;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
NGINXEOF

rm -f /etc/nginx/sites-enabled/default
ln -sf "$NGINX_CONF" "$NGINX_ENABLED"
nginx -t

# ── 4. CREATE APP ────────────────────────────────────────────
echo -e "${YELLOW}[4/5] Création de l'application...${NC}"

cat > "$APP_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=1920, height=1080, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<title>PlezyTV</title>
<style>

/* ═══════════════════════════════════════
   RESET
═══════════════════════════════════════ */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  outline: none;
  -webkit-tap-highlight-color: transparent;
}

:root {
  --bg:           #0a0a0f;
  --bg2:          #111118;
  --bg3:          #1a1a28;
  --bg4:          #222234;
  --accent:       #e50914;
  --accent2:      #ff3b3b;
  --accentglow:   rgba(229,9,20,0.45);
  --text:         #ffffff;
  --text2:        #a0a0b8;
  --text3:        #555568;
  --border:       rgba(255,255,255,0.07);
  --radius:       12px;
  --tr:           0.18s ease;
}

html, body {
  width: 1920px;
  height: 1080px;
  overflow: hidden;
  background: var(--bg);
  color: var(--text);
  font-family: 'Segoe UI', Arial, sans-serif;
  font-size: 16px;
  -webkit-font-smoothing: antialiased;
  user-select: none;
}

/* ═══════════════════════════════════════
   SCREENS
═══════════════════════════════════════ */
.screen {
  position: absolute;
  inset: 0;
  display: none;
}
.screen.active { display: flex; }

/* ═══════════════════════════════════════
   SCREEN LOGIN
═══════════════════════════════════════ */
#s-login {
  align-items: center;
  justify-content: center;
  background: radial-gradient(ellipse at 60% 40%, rgba(229,9,20,0.08) 0%, transparent 60%),
              var(--bg);
}

.login-box {
  width: 580px;
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: 24px;
  padding: 52px 60px;
  box-shadow: 0 40px 100px rgba(0,0,0,0.7);
}

.login-logo {
  text-align: center;
  margin-bottom: 44px;
}

.login-logo-icon {
  width: 76px;
  height: 76px;
  background: var(--accent);
  border-radius: 18px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 18px;
  box-shadow: 0 8px 32px var(--accentglow);
}

.login-logo-icon svg { width: 40px; height: 40px; fill: #fff; }

.login-logo h1 {
  font-size: 34px;
  font-weight: 800;
  letter-spacing: -0.5px;
}
.login-logo h1 span { color: var(--accent); }

.login-logo p {
  font-size: 14px;
  color: var(--text2);
  margin-top: 6px;
}

.field { margin-bottom: 22px; }

.field label {
  display: block;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: var(--text2);
  margin-bottom: 9px;
}

.field input {
  width: 100%;
  padding: 15px 18px;
  background: var(--bg2);
  border: 2px solid var(--border);
  border-radius: 10px;
  color: var(--text);
  font-size: 16px;
  font-family: inherit;
  transition: border-color var(--tr), box-shadow var(--tr);
}

.field input.f-focused,
.field input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accentglow);
}

.field input::placeholder { color: var(--text3); }

.btn-connect {
  width: 100%;
  padding: 17px;
  background: var(--accent);
  border: none;
  border-radius: 10px;
  color: #fff;
  font-size: 17px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
  transition: background var(--tr), box-shadow var(--tr), transform var(--tr);
  margin-top: 4px;
}

.btn-connect.f-focused,
.btn-connect:hover {
  background: var(--accent2);
  box-shadow: 0 0 0 3px var(--accentglow);
  transform: translateY(-1px);
}

.login-err {
  margin-top: 16px;
  padding: 13px 16px;
  background: rgba(229,9,20,0.1);
  border: 1px solid rgba(229,9,20,0.3);
  border-radius: 9px;
  color: #ff7070;
  font-size: 14px;
  text-align: center;
  display: none;
}
.login-err.show { display: block; }

.login-spin {
  text-align: center;
  padding-top: 22px;
  display: none;
}
.login-spin.show { display: block; }

.spinner {
  width: 34px;
  height: 34px;
  border: 3px solid var(--border);
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 0.75s linear infinite;
  display: inline-block;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ═══════════════════════════════════════
   SCREEN APP
═══════════════════════════════════════ */
#s-app { flex-direction: row; }

/* ── SIDEBAR ───────────────────────── */
.sidebar {
  width: 230px;
  flex-shrink: 0;
  background: var(--bg2);
  border-right: 1px solid var(--border);
  display: flex;
  flex-direction: column;
  padding: 28px 0;
  z-index: 20;
}

.sb-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 24px 28px;
  border-bottom: 1px solid var(--border);
  margin-bottom: 14px;
}

.sb-logo-icon {
  width: 38px;
  height: 38px;
  background: var(--accent);
  border-radius: 9px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.sb-logo-icon svg { width: 20px; height: 20px; fill: #fff; }

.sb-logo-txt {
  font-size: 21px;
  font-weight: 800;
}
.sb-logo-txt span { color: var(--accent); }

.sb-section {
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1.2px;
  color: var(--text3);
  padding: 14px 24px 6px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 13px;
  padding: 13px 24px;
  font-size: 15px;
  font-weight: 500;
  color: var(--text2);
  cursor: pointer;
  border-left: 3px solid transparent;
  transition: all var(--tr);
}
.nav-item svg { width: 20px; height: 20px; fill: currentColor; flex-shrink: 0; }

.nav-item.active {
  color: var(--accent);
  border-left-color: var(--accent);
  background: rgba(229,9,20,0.08);
}

.nav-item.f-focused {
  color: var(--text);
  background: rgba(255,255,255,0.06);
  box-shadow: inset 3px 0 0 var(--accent);
}

.sb-user {
  margin-top: auto;
  padding: 18px 24px;
  border-top: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 11px;
}

.sb-avatar {
  width: 36px;
  height: 36px;
  background: var(--accent);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 15px;
  font-weight: 700;
  flex-shrink: 0;
}

.sb-user-info { flex: 1; min-width: 0; }
.sb-username {
  font-size: 14px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.sb-server {
  font-size: 11px;
  color: var(--text3);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.btn-logout {
  width: 30px;
  height: 30px;
  background: transparent;
  border: 1px solid var(--border);
  border-radius: 7px;
  color: var(--text3);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all var(--tr);
}
.btn-logout svg { width: 15px; height: 15px; fill: currentColor; }
.btn-logout.f-focused, .btn-logout:hover {
  border-color: var(--accent);
  color: var(--accent);
}

/* ── MAIN ─────────────────────────── */
.main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
}

/* ── TOPBAR ──────────────────────── */
.topbar {
  height: 74px;
  display: flex;
  align-items: center;
  padding: 0 44px;
  border-bottom: 1px solid var(--border);
  flex-shrink: 0;
  gap: 20px;
}

.topbar-title {
  font-size: 26px;
  font-weight: 700;
  flex: 1;
}

/* ── VIEWS ───────────────────────── */
.view { display: none; flex-direction: column; flex: 1; overflow: hidden; }
.view.active { display: flex; }

/* ═══════════════════════════════════════
   VIEW: HOME
═══════════════════════════════════════ */
.home-scroll {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 32px 44px 44px;
  scroll-behavior: smooth;
}
.home-scroll::-webkit-scrollbar { width: 5px; }
.home-scroll::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 3px; }

/* ── HERO ────────────────────────── */
.hero {
  position: relative;
  height: 380px;
  border-radius: 18px;
  overflow: hidden;
  margin-bottom: 38px;
  cursor: pointer;
  flex-shrink: 0;
}
.hero-bg {
  position: absolute;
  inset: 0;
  background: var(--bg3);
}
.hero-bg img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.45;
}
.hero-grad {
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, rgba(10,10,15,0.96) 0%, rgba(10,10,15,0.55) 55%, transparent 100%);
}
.hero-body {
  position: relative;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 44px;
  max-width: 580px;
}
.hero-tag {
  display: inline-block;
  padding: 4px 11px;
  background: var(--accent);
  border-radius: 4px;
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 11px;
}
.hero-title {
  font-size: 40px;
  font-weight: 800;
  line-height: 1.1;
  margin-bottom: 10px;
  letter-spacing: -0.5px;
}
.hero-meta {
  font-size: 13px;
  color: var(--text2);
  margin-bottom: 14px;
  display: flex;
  align-items: center;
  gap: 14px;
}
.dot {
  width: 3px;
  height: 3px;
  border-radius: 50%;
  background: var(--text3);
  flex-shrink: 0;
}
.hero-desc {
  font-size: 14px;
  color: var(--text2);
  line-height: 1.6;
  margin-bottom: 26px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.hero-btns { display: flex; gap: 14px; }

.hbtn {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 13px 26px;
  border-radius: 9px;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  border: none;
  font-family: inherit;
  transition: all var(--tr);
}
.hbtn svg { width: 18px; height: 18px; fill: currentColor; }

.hbtn-play {
  background: var(--accent);
  color: #fff;
}
.hbtn-play.f-focused, .hbtn-play:hover {
  background: var(--accent2);
  box-shadow: 0 0 0 3px var(--accentglow);
}

.hbtn-info {
  background: rgba(255,255,255,0.14);
  color: #fff;
}
.hbtn-info.f-focused, .hbtn-info:hover {
  background: rgba(255,255,255,0.24);
}

.hero.f-focused { box-shadow: 0 0 0 3px var(--accent), 0 0 20px var(--accentglow); }

/* ── SECTIONS ────────────────────── */
.section { margin-bottom: 36px; }

.section-hdr {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.section-title { font-size: 20px; font-weight: 700; }

/* ── CARD ROW ────────────────────── */
.row {
  display: flex;
  gap: 18px;
  overflow-x: auto;
  overflow-y: visible;
  padding-bottom: 10px;
  scroll-behavior: smooth;
}
.row::-webkit-scrollbar { height: 3px; }
.row::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 2px; }

/* ── CARD ────────────────────────── */
.card {
  flex-shrink: 0;
  width: 200px;
  cursor: pointer;
  transition: transform 0.22s ease;
  position: relative;
}
.card:hover, .card.f-focused {
  transform: scale(1.07) translateY(-5px);
  z-index: 5;
}

.card-img {
  width: 100%;
  aspect-ratio: 2/3;
  border-radius: var(--radius);
  overflow: hidden;
  background: var(--bg3);
  position: relative;
}
.card-img img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
.card-img-ph {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  background: linear-gradient(135deg, var(--bg3), var(--bg4));
}
.card-img-ph svg { width: 44px; height: 44px; fill: var(--text3); }
.card-img-ph span { font-size: 12px; color: var(--text3); text-align: center; padding: 0 10px; }

.card.f-focused .card-img {
  box-shadow: 0 0 0 3px var(--accent), 0 0 18px var(--accentglow);
}

.card-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.75) 0%, transparent 50%);
  border-radius: var(--radius);
  opacity: 0;
  transition: opacity var(--tr);
  display: flex;
  align-items: center;
  justify-content: center;
}
.card:hover .card-overlay, .card.f-focused .card-overlay { opacity: 1; }

.card-play {
  width: 48px;
  height: 48px;
  background: rgba(229,9,20,0.92);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.card-play svg { width: 20px; height: 20px; fill: #fff; margin-left: 3px; }

.card-prog {
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 4px;
  background: rgba(0,0,0,0.4);
}
.card-prog-bar {
  height: 100%;
  background: var(--accent);
  border-radius: 2px;
}

.card-info { padding: 10px 3px 0; }
.card-title {
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 3px;
}
.card-year { font-size: 12px; color: var(--text3); }

/* ═══════════════════════════════════════
   VIEW: LIBRARY (Movies / Series)
═══════════════════════════════════════ */
.lib-header {
  display: flex;
  align-items: center;
  gap: 28px;
  padding: 0 44px;
  height: 64px;
  border-bottom: 1px solid var(--border);
  flex-shrink: 0;
}

.lib-title { font-size: 22px; font-weight: 700; margin-right: auto; }

.ftab {
  padding: 8px 18px;
  border-radius: 8px;
  border: 2px solid var(--border);
  background: transparent;
  color: var(--text2);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
  transition: all var(--tr);
}
.ftab.active { border-color: var(--accent); color: var(--accent); background: rgba(229,9,20,0.08); }
.ftab.f-focused {
  border-color: var(--accent);
  color: var(--text);
  box-shadow: 0 0 0 2px var(--accentglow);
}

.lib-scroll {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 28px 44px;
  scroll-behavior: smooth;
}
.lib-scroll::-webkit-scrollbar { width: 5px; }
.lib-scroll::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 3px; }

.lib-grid {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 22px;
}

/* ═══════════════════════════════════════
   VIEW: DETAIL
═══════════════════════════════════════ */
.detail-scroll {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  scroll-behavior: smooth;
}
.detail-scroll::-webkit-scrollbar { width: 5px; }
.detail-scroll::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 3px; }

.detail-hero {
  position: relative;
  height: 420px;
  overflow: hidden;
  flex-shrink: 0;
}
.detail-hero-bg {
  position: absolute;
  inset: 0;
  background: var(--bg3);
}
.detail-hero-bg img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.35;
}
.detail-hero-grad {
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom,
    transparent 0%,
    rgba(10,10,15,0.3) 50%,
    rgba(10,10,15,1) 100%
  );
}

.detail-body {
  position: relative;
  padding: 0 60px 60px;
  margin-top: -180px;
  display: flex;
  gap: 48px;
  align-items: flex-start;
}

.detail-poster {
  width: 220px;
  flex-shrink: 0;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0,0,0,0.7);
  aspect-ratio: 2/3;
  background: var(--bg3);
  position: relative;
  z-index: 2;
}
.detail-poster img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}
.detail-poster-ph {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.detail-poster-ph svg { width: 60px; height: 60px; fill: var(--text3); }

.detail-info {
  flex: 1;
  padding-top: 120px;
  z-index: 2;
}

.detail-genres {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 14px;
}
.genre-tag {
  padding: 4px 12px;
  border-radius: 5px;
  background: rgba(229,9,20,0.15);
  border: 1px solid rgba(229,9,20,0.3);
  color: var(--accent2);
  font-size: 12px;
  font-weight: 600;
}

.detail-title {
  font-size: 46px;
  font-weight: 800;
  line-height: 1.05;
  letter-spacing: -1px;
  margin-bottom: 14px;
}

.detail-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 14px;
  color: var(--text2);
  margin-bottom: 18px;
}

.rating-badge {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #ffd700;
  font-weight: 700;
}
.rating-badge svg { width: 16px; height: 16px; fill: #ffd700; }

.detail-overview {
  font-size: 15px;
  color: var(--text2);
  line-height: 1.7;
  max-width: 680px;
  margin-bottom: 28px;
}

.detail-btns { display: flex; gap: 14px; margin-bottom: 40px; }

.dbtn {
  display: flex;
  align-items: center;
  gap: 9px;
  padding: 15px 30px;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  border: none;
  font-family: inherit;
  transition: all var(--tr);
}
.dbtn svg { width: 20px; height: 20px; fill: currentColor; }

.dbtn-play {
  background: var(--accent);
  color: #fff;
}
.dbtn-play.f-focused, .dbtn-play:hover {
  background: var(--accent2);
  box-shadow: 0 0 0 3px var(--accentglow);
  transform: translateY(-1px);
}

.dbtn-back {
  background: rgba(255,255,255,0.1);
  color: #fff;
  border: 1px solid var(--border);
}
.dbtn-back.f-focused, .dbtn-back:hover {
  background: rgba(255,255,255,0.18);
}

/* ── SEASON SELECTOR ──────────────── */
.season-tabs {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 20px;
}

.stab {
  padding: 8px 18px;
  border-radius: 8px;
  border: 2px solid var(--border);
  background: transparent;
  color: var(--text2);
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  font-family: inherit;
  transition: all var(--tr);
}
.stab.active { border-color: var(--accent); color: var(--accent); background: rgba(229,9,20,0.08); }
.stab.f-focused {
  border-color: var(--accent);
  color: var(--text);
  box-shadow: 0 0 0 2px var(--accentglow);
}

/* ── EPISODE LIST ────────────────── */
.ep-list { display: flex; flex-direction: column; gap: 10px; }

.ep-item {
  display: flex;
  gap: 18px;
  background: var(--bg3);
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all var(--tr);
}
.ep-item:hover, .ep-item.f-focused {
  border-color: var(--accent);
  background: var(--bg4);
}

.ep-thumb {
  width: 192px;
  flex-shrink: 0;
  aspect-ratio: 16/9;
  background: var(--bg4);
  position: relative;
  overflow: hidden;
}
.ep-thumb img { width: 100%; height: 100%; object-fit: cover; }
.ep-thumb-ph {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.ep-thumb-ph svg { width: 34px; height: 34px; fill: var(--text3); }

.ep-dur {
  position: absolute;
  bottom: 6px; right: 6px;
  background: rgba(0,0,0,0.78);
  padding: 2px 7px;
  border-radius: 4px;
  font-size: 11px;
}

.ep-info {
  flex: 1;
  padding: 14px 18px 14px 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.ep-num {
  font-size: 11px;
  font-weight: 700;
  color: var(--accent);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 5px;
}
.ep-name {
  font-size: 15px;
  font-weight: 700;
  margin-bottom: 6px;
}
.ep-overview {
  font-size: 13px;
  color: var(--text2);
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  line-height: 1.5;
}
.ep-runtime {
  font-size: 12px;
  color: var(--text3);
  margin-top: 7px;
}

/* ── SECTION SUB ──────────────────── */
.subsection { margin-top: 0; }
.subsection-title {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 16px;
}

/* ═══════════════════════════════════════
   VIEW: SEARCH
═══════════════════════════════════════ */
.search-wrap {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 28px 44px;
  overflow: hidden;
}

.search-input-wrap {
  position: relative;
  flex-shrink: 0;
  margin-bottom: 28px;
}
.search-icon {
  position: absolute;
  left: 18px;
  top: 50%;
  transform: translateY(-50%);
  width: 22px;
  height: 22px;
  fill: var(--text3);
}
.search-big {
  width: 100%;
  padding: 19px 22px 19px 52px;
  background: var(--bg3);
  border: 2px solid var(--border);
  border-radius: 14px;
  color: var(--text);
  font-size: 19px;
  font-family: inherit;
  transition: border-color var(--tr), box-shadow var(--tr);
}
.search-big.f-focused, .search-big:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accentglow);
}
.search-big::placeholder { color: var(--text3); }

.search-results {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}
.search-results::-webkit-scrollbar { width: 5px; }
.search-results::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 3px; }

.search-grid {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 22px;
}

.search-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 280px;
  gap: 14px;
  color: var(--text3);
}
.search-empty svg { width: 58px; height: 58px; fill: currentColor; opacity: 0.35; }
.search-empty p { font-size: 17px; }

/* ═══════════════════════════════════════
   PLAYER
═══════════════════════════════════════ */
#s-player {
  position: fixed;
  inset: 0;
  background: #000;
  z-index: 200;
  display: none;
  align-items: center;
  justify-content: center;
}
#s-player.active { display: flex; }

#player-vid {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.player-ui {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  background: linear-gradient(to top, rgba(0,0,0,0.88) 0%, transparent 38%);
  opacity: 0;
  transition: opacity 0.28s;
  pointer-events: none;
}
.player-ui.show { opacity: 1; pointer-events: all; }

.player-info-bar { padding: 0 48px 6px; }
.player-vid-title { font-size: 24px; font-weight: 700; margin-bottom: 3px; }
.player-vid-sub { font-size: 14px; color: var(--text2); }

.player-prog-wrap { padding: 0 48px; margin-bottom: 10px; }

.player-prog-bg {
  width: 100%;
  height: 5px;
  background: rgba(255,255,255,0.2);
  border-radius: 3px;
  position: relative;
  cursor: pointer;
}
.player-prog-fill {
  height: 100%;
  background: var(--accent);
  border-radius: 3px;
  pointer-events: none;
}
.player-prog-thumb {
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%) scale(0);
  width: 15px;
  height: 15px;
  background: #fff;
  border-radius: 50%;
  transition: transform 0.18s;
  pointer-events: none;
}
.player-ui.show .player-prog-thumb { transform: translate(-50%, -50%) scale(1); }

.player-times {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--text2);
  margin-top: 7px;
}

.player-btns {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 0 48px 36px;
}

.pbtn {
  width: 50px;
  height: 50px;
  background: rgba(255,255,255,0.1);
  border: none;
  border-radius: 50%;
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--tr);
}
.pbtn svg { width: 22px; height: 22px; fill: currentColor; }
.pbtn.f-focused, .pbtn:hover { background: rgba(255,255,255,0.22); }

.pbtn-main {
  width: 62px;
  height: 62px;
  background: var(--accent);
}
.pbtn-main.f-focused, .pbtn-main:hover {
  background: var(--accent2);
  box-shadow: 0 0 0 3px var(--accentglow);
}
.pbtn-main svg { width: 26px; height: 26px; }

.player-vol {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 10px;
}
.player-vol svg { width: 20px; height: 20px; fill: #fff; }
.vol-track {
  width: 90px;
  height: 4px;
  background: rgba(255,255,255,0.18);
  border-radius: 2px;
}
.vol-fill {
  height: 100%;
  background: #fff;
  border-radius: 2px;
  width: 80%;
  transition: width var(--tr);
}

.player-err {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 18px;
  background: rgba(0,0,0,0.85);
  display: none;
}
.player-err.show { display: flex; }
.player-err-icon { font-size: 56px; }
.player-err-msg { font-size: 18px; color: var(--text2); }
.player-err-btn {
  margin-top: 8px;
  padding: 14px 32px;
  background: var(--accent);
  border: none;
  border-radius: 9px;
  color: #fff;
  font-size: 15px;
  font-weight: 700;
  font-family: inherit;
  cursor: pointer;
}

/* ═══════════════════════════════════════
   LOADING / EMPTY / TOAST
═══════════════════════════════════════ */
.loading-layer {
  position: absolute;
  inset: 0;
  background: rgba(10,10,15,0.82);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 18px;
  z-index: 80;
  display: none;
}
.loading-layer.show { display: flex; }
.loading-layer p { font-size: 17px; color: var(--text2); }

.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 260px;
  gap: 14px;
  color: var(--text3);
}
.empty svg { width: 66px; height: 66px; fill: currentColor; opacity: 0.28; }
.empty p { font-size: 17px; }

.toast {
  position: fixed;
  bottom: 44px;
  left: 50%;
  transform: translateX(-50%) translateY(80px);
  background: var(--bg3);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 13px 26px;
  font-size: 15px;
  box-shadow: 0 8px 30px rgba(0,0,0,0.5);
  z-index: 999;
  transition: transform 0.28s ease;
  white-space: nowrap;
}
.toast.show { transform: translateX(-50%) translateY(0); }

/* ─── FOCUS OUTLINE GLOBAL ─────────── */
[data-f].f-focused { outline: none; }

@keyframes fadein {
  from { opacity:0; transform:translateY(8px); }
  to   { opacity:1; transform:translateY(0); }
}
.fadein { animation: fadein 0.28s ease both; }

</style>
</head>
<body>

<!-- ══════════════════════════════
     LOGIN
══════════════════════════════ -->
<div id="s-login" class="screen active">
  <div class="login-box" id="login-box">
    <div class="login-logo">
      <div class="login-logo-icon">
        <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
      </div>
      <h1>Plezy<span>TV</span></h1>
      <p>Connectez votre serveur Jellyfin</p>
    </div>

    <div class="field">
      <label>Adresse du serveur</label>
      <input id="inp-server" type="text" placeholder="http://192.168.1.100:8096" data-f>
    </div>
    <div class="field">
      <label>Nom d'utilisateur</label>
      <input id="inp-user" type="text" placeholder="admin" data-f>
    </div>
    <div class="field">
      <label>Mot de passe</label>
      <input id="inp-pass" type="password" placeholder="••••••••" data-f>
    </div>

    <button class="btn-connect" id="btn-connect" data-f>Se connecter</button>

    <div class="login-err" id="login-err"></div>
    <div class="login-spin" id="login-spin">
      <div class="spinner"></div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════
     APP
══════════════════════════════ -->
<div id="s-app" class="screen">

  <!-- SIDEBAR -->
  <nav class="sidebar">
    <div class="sb-logo">
      <div class="sb-logo-icon">
        <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
      </div>
      <div class="sb-logo-txt">Plezy<span>TV</span></div>
    </div>

    <div class="sb-section">Menu</div>

    <div class="nav-item active" data-nav="home" data-f id="nav-home">
      <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
      <span>Accueil</span>
    </div>
    <div class="nav-item" data-nav="movies" data-f id="nav-movies">
      <svg viewBox="0 0 24 24"><path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/></svg>
      <span>Films</span>
    </div>
    <div class="nav-item" data-nav="series" data-f id="nav-series">
      <svg viewBox="0 0 24 24"><path d="M21 3H3c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h5v2h8v-2h5c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 14H3V5h18v12z"/></svg>
      <span>Séries</span>
    </div>
    <div class="nav-item" data-nav="search" data-f id="nav-search">
      <svg viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
      <span>Recherche</span>
    </div>

    <div class="sb-user">
      <div class="sb-avatar" id="sb-avatar">J</div>
      <div class="sb-user-info">
        <div class="sb-username" id="sb-username">Utilisateur</div>
        <div class="sb-server" id="sb-server">jellyfin</div>
      </div>
      <button class="btn-logout" id="btn-logout" data-f>
        <svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5-5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
      </button>
    </div>
  </nav>

  <!-- MAIN -->
  <main class="main">
    <div class="topbar">
      <div class="topbar-title" id="topbar-title">Accueil</div>
    </div>

    <!-- VIEW HOME -->
    <div class="view active" id="v-home">
      <div class="home-scroll" id="home-scroll">

        <div class="hero fadein" id="hero" data-f>
          <div class="hero-bg"><img id="hero-img" src="" alt=""></div>
          <div class="hero-grad"></div>
          <div class="hero-body">
            <span class="hero-tag" id="hero-tag">Film</span>
            <div class="hero-title" id="hero-title">Chargement...</div>
            <div class="hero-meta" id="hero-meta"></div>
            <div class="hero-desc" id="hero-desc"></div>
            <div class="hero-btns">
              <button class="hbtn hbtn-play" id="hero-play" data-f>
                <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                Lire
              </button>
              <button class="hbtn hbtn-info" id="hero-info" data-f>
                <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                Détails
              </button>
            </div>
          </div>
        </div>

        <div class="section" id="sec-resume" style="display:none">
          <div class="section-hdr">
            <div class="section-title">Continuer à regarder</div>
          </div>
          <div class="row" id="row-resume"></div>
        </div>

        <div class="section">
          <div class="section-hdr">
            <div class="section-title">Récemment ajoutés</div>
          </div>
          <div class="row" id="row-recent"></div>
        </div>

        <div class="section">
          <div class="section-hdr">
            <div class="section-title">Films</div>
          </div>
          <div class="row" id="row-movies"></div>
        </div>

        <div class="section">
          <div class="section-hdr">
            <div class="section-title">Séries</div>
          </div>
          <div class="row" id="row-series"></div>
        </div>

      </div>
    </div>

    <!-- VIEW MOVIES -->
    <div class="view" id="v-movies">
      <div class="lib-header">
        <div class="lib-title">Films</div>
        <button class="ftab active" data-sort="DateCreated,desc" data-f>Récents</button>
        <button class="ftab" data-sort="SortName,asc" data-f>A–Z</button>
        <button class="ftab" data-sort="CommunityRating,desc" data-f>Mieux notés</button>
        <button class="ftab" data-sort="PremiereDate,desc" data-f>Année</button>
      </div>
      <div class="lib-scroll">
        <div class="lib-grid" id="grid-movies"></div>
      </div>
    </div>

    <!-- VIEW SERIES -->
    <div class="view" id="v-series">
      <div class="lib-header">
        <div class="lib-title">Séries</div>
        <button class="ftab active" data-sort="DateCreated,desc" data-f>Récentes</button>
        <button class="ftab" data-sort="SortName,asc" data-f>A–Z</button>
        <button class="ftab" data-sort="CommunityRating,desc" data-f>Mieux notées</button>
      </div>
      <div class="lib-scroll">
        <div class="lib-grid" id="grid-series"></div>
      </div>
    </div>

    <!-- VIEW DETAIL -->
    <div class="view" id="v-detail">
      <div class="detail-scroll" id="detail-scroll">
        <div class="detail-hero">
          <div class="detail-hero-bg"><img id="d-hero-img" src="" alt=""></div>
          <div class="detail-hero-grad"></div>
        </div>
        <div class="detail-body">
          <div class="detail-poster">
            <img id="d-poster" src="" alt="" style="display:none">
            <div class="detail-poster-ph" id="d-poster-ph">
              <svg viewBox="0 0 24 24"><path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/></svg>
            </div>
          </div>
          <div class="detail-info">
            <div class="detail-genres" id="d-genres"></div>
            <div class="detail-title" id="d-title"></div>
            <div class="detail-meta" id="d-meta"></div>
            <div class="detail-overview" id="d-overview"></div>
            <div class="detail-btns">
              <button class="dbtn dbtn-play" id="d-play" data-f>
                <svg viewBox="0 0 24 24"><path d="M8 5v14l11-7z"/></svg>
                Lire
              </button>
              <button class="dbtn dbtn-back" id="d-back" data-f>
                <svg viewBox="0 0 24 24"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
                Retour
              </button>
            </div>
            <div id="d-episodes-section" style="display:none">
              <div class="season-tabs" id="d-seasons"></div>
              <div class="ep-list" id="d-eplist"></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- VIEW SEARCH -->
    <div class="view" id="v-search">
      <div class="search-wrap">
        <div class="search-input-wrap">
          <svg class="search-icon" viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
          <input class="search-big" id="search-big" type="text" placeholder="Rechercher films, séries..." data-f>
        </div>
        <div class="search-results" id="search-results">
          <div class="search-empty" id="search-empty">
            <svg viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
            <p>Commencez à taper pour rechercher</p>
          </div>
          <div class="search-grid" id="search-grid" style="display:none"></div>
        </div>
      </div>
    </div>

  </main>

  <div class="loading-layer" id="loading-layer">
    <div class="spinner"></div>
    <p>Chargement...</p>
  </div>

</div>

<!-- ══════════════════════════════
     PLAYER
══════════════════════════════ -->
<div id="s-player" class="screen">
  <video id="player-vid" playsinline></video>
  <div class="player-ui" id="player-ui">
    <div class="player-info-bar">
      <div class="player-vid-title" id="player-title"></div>
      <div class="player-vid-sub" id="player-sub"></div>
    </div>
    <div class="player-prog-wrap">
      <div class="player-prog-bg" id="player-prog-bg">
        <div class="player-prog-fill" id="player-prog-fill" style="width:0%"></div>
        <div class="player-prog-thumb" id="player-prog-thumb" style="left:0%"></div>
      </div>
      <div class="player-times">
        <span id="player-cur">0:00</span>
        <span id="player-dur">0:00</span>
      </div>
    </div>
    <div class="player-btns">
      <button class="pbtn" id="pbtn-back" data-f>
        <svg viewBox="0 0 24 24"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
      </button>
      <button class="pbtn" id="pbtn-rw" data-f>
        <svg viewBox="0 0 24 24"><path d="M11 18V6l-8.5 6 8.5 6zm.5-6l8.5 6V6l-8.5 6z"/></svg>
      </button>
      <button class="pbtn pbtn-main" id="pbtn-play" data-f>
        <svg viewBox="0 0 24 24" id="pbtn-play-icon"><path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/></svg>
      </button>
      <button class="pbtn" id="pbtn-ff" data-f>
        <svg viewBox="0 0 24 24"><path d="M4 18l8.5-6L4 6v12zm9-12v12l8.5-6L13 6z"/></svg>
      </button>
      <div class="player-vol">
        <svg viewBox="0 0 24 24"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/></svg>
        <div class="vol-track"><div class="vol-fill" id="vol-fill"></div></div>
      </div>
    </div>
  </div>
  <div class="player-err" id="player-err">
    <div class="player-err-icon">⚠️</div>
    <div class="player-err-msg" id="player-err-msg">Erreur de lecture</div>
    <button class="player-err-btn" id="player-err-close" data-f>Fermer</button>
  </div>
</div>

<!-- TOAST -->
<div class="toast" id="toast"></div>

<script>
// ═══════════════════════════════════════════════════
//  PLEZY-TV — JELLYFIN CLIENT
//  VidaaOS / Hisense 43