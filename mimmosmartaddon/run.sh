#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Avvio MimmoSmart FRPC add-on..."

OPTIONS_FILE="/data/options.json"

if [ ! -f "$OPTIONS_FILE" ]; then
    echo "[FATAL] File di configurazione /data/options.json non trovato!"
    exit 1
fi

# --- Leggo configurazione via JQ ---
FRP_SERVER_ADDR=$(jq -r '.frp_server_addr // empty' "$OPTIONS_FILE")
FRP_SERVER_PORT=$(jq -r '.frp_server_port // 7000' "$OPTIONS_FILE")
FRP_SHARED_TOKEN=$(jq -r '.frp_shared_token // empty' "$OPTIONS_FILE")
LOCAL_IP=$(jq -r '.local_ip // "127.0.0.1"' "$OPTIONS_FILE")
LOCAL_PORT=$(jq -r '.local_port // 8123' "$OPTIONS_FILE")
SUBDOMAIN=$(jq -r '.subdomain // empty' "$OPTIONS_FILE")
CUSTOM_DOMAIN=$(jq -r '.custom_domain // empty' "$OPTIONS_FILE")

# --- Validazione ---
if [ -z "${FRP_SERVER_ADDR}" ] || [ -z "${FRP_SHARED_TOKEN}" ]; then
  echo "[FATAL] frp_server_addr e frp_shared_token sono obbligatori!"
  exit 1
fi

# --- Calcolo NAMESPACE ---
NAMESPACE="${SUBDOMAIN}"
if [ -z "$NAMESPACE" ] && [ -n "${CUSTOM_DOMAIN}" ]; then
  NAMESPACE="${CUSTOM_DOMAIN%%.*}"
fi
if [ -z "$NAMESPACE" ]; then
  NAMESPACE="$(hostname)"
fi

# --- Identificazione Architettura ---
ARCH=$(uname -m)
case "$ARCH" in
  x86_64)   FRP_ARCH="linux_amd64" ;;
  aarch64)  FRP_ARCH="linux_arm64" ;;
  armv7l)   FRP_ARCH="linux_arm" ;;
  i386)     FRP_ARCH="linux_386" ;;
  *)        echo "[FATAL] Architettura non supportata: $ARCH"; exit 1 ;;
esac

FRP_VERSION="0.64.0"
FRP_TGZ="frp_${FRP_VERSION}_${FRP_ARCH}.tar.gz"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FRP_TGZ}"

if [ ! -x /data/frpc ]; then
  echo "[INFO] Scarico frpc ${FRP_VERSION} (${FRP_ARCH})..."
  TMPDIR=$(mktemp -d)
  curl -fsSL -o "${TMPDIR}/${FRP_TGZ}" "${FRP_URL}"
  tar -xzf "${TMPDIR}/${FRP_TGZ}" -C "${TMPDIR}"
  cp "${TMPDIR}/frp_${FRP_VERSION}_${FRP_ARCH}/frpc" /data/frpc
  chmod +x /data/frpc
  rm -rf "${TMPDIR}"
fi

# --- Generazione Configurazione INI ---
echo "[INFO] Configuro FRPC..."
CONFIG_PATH="/data/frpc.ini"

cat > "${CONFIG_PATH}" <<EOF
[common]
server_addr = ${FRP_SERVER_ADDR}
server_port = ${FRP_SERVER_PORT}
token = ${FRP_SHARED_TOKEN}
login_fail_exit = false
tls_enable = true
user = ${NAMESPACE}

[homeassistant]
type = http
local_ip = ${LOCAL_IP}
local_port = ${LOCAL_PORT}
EOF

if [ -n "${CUSTOM_DOMAIN}" ]; then
  echo "custom_domains = ${CUSTOM_DOMAIN}" >> "${CONFIG_PATH}"
elif [ -n "${SUBDOMAIN}" ]; then
  echo "subdomain = ${SUBDOMAIN}" >> "${CONFIG_PATH}"
fi

echo "[INFO] Configurazione creata per Namespace: ${NAMESPACE}"

# --- Avvio FRPC ---
echo "[INFO] Avvio frpc in corso..."
exec /data/frpc -c "${CONFIG_PATH}"
