#!/usr/bin/env bash
set -euo pipefail

# ======= CONFIG =======
RSYNC_HOST="glpi.forumtelecom.com.br"   # seu servidor central (rsync daemon)
RSYNC_USER="aluno"                      # usuário do rsyncd
RSYNC_PASS="forumtelecom@#$"            # senha do rsyncd
RSYNC_MODULE="hotspot"                  # módulo no rsyncd
TARGET_DIR="/var/www/hotspot"           # pasta do sistema no aluno
PM2_PROCESS="hotspot-api"               # nome fixo no PM2
# ======================

# PATH básico pra achar npm/pm2 mesmo em shells "magros"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Checagens simples (não instala nada automaticamente)
command -v rsync >/dev/null || { echo "❌ rsync não encontrado. Instale: sudo apt-get install -y rsync"; exit 1; }

# Excludes que NÃO devem sobrescrever no aluno
EXCLUDES=(
  "--exclude" "backend/.env"
  "--exclude" "frontend/.env"
  "--exclude" "backend/node_modules/"
  "--exclude" "frontend/node_modules/"
  "--exclude" "uploads/"
  "--exclude" "logs/"
  "--exclude" "backend/tokens/"
)

# Arquivo de senha temporário para o rsync
PASSFILE="$(mktemp)"
chmod 600 "$PASSFILE"
printf '%s\n' "$RSYNC_PASS" > "$PASSFILE"

# 1) RSYNC: servidor -> aluno
mkdir -p "$TARGET_DIR"
echo "[SYNC] rsync://${RSYNC_HOST}/${RSYNC_MODULE} -> ${TARGET_DIR}"
rsync -az --delete \
  "${EXCLUDES[@]}" \
  "rsync://${RSYNC_USER}@${RSYNC_HOST}/${RSYNC_MODULE}/" \
  "$TARGET_DIR"/ \
  --password-file="$PASSFILE"
echo "[SYNC] OK"

# 2) BUILD FRONTEND (sempre, se existir)
if command -v npm >/dev/null && [[ -d "${TARGET_DIR}/frontend" ]]; then
  echo "[BUILD] Frontend: npm ci && npm run build"
  ( cd "${TARGET_DIR}/frontend" && npm ci && npm run build )
  echo "[BUILD] OK"
else
  echo "[BUILD] Pulado (npm não encontrado ou pasta frontend ausente)."
fi

# 3) PM2: stop/start do backend
if command -v pm2 >/dev/null; then
  # garante HOME do root para evitar /etc/.pm2
  export HOME="$(getent passwd root | cut -d: -f6 || echo /root)"
  echo "[PM2] Reiniciando ${PM2_PROCESS}"
  pm2 stop "${PM2_PROCESS}" || true
  pm2 start "${PM2_PROCESS}"
  echo "[PM2] OK"
else
  echo "[PM2] pm2 não encontrado; reinício do backend pulado."
fi

# Limpa o arquivo de senha
rm -f "$PASSFILE"

echo "[DONE] Sync + build + restart concluído."
