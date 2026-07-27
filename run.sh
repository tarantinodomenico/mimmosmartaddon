#!/usr/bin/with-contenv bashio
set -euo pipefail

bashio::log.info "Avvio MimmoSmart FRPC add-on..."

# --- Leggo configurazione dall’UI dell’add-on ---
FRP_SERVER_ADDR=$(bashio::config 'frp_server_addr')
FRP_SERVER_PORT=$(bashio::config 'frp_server_port' '7000')
FRP_SHARED_TOKEN=$(bashio::config 'frp_shared_token')
LOCAL_IP=$(bashio::config 'local_ip' '127.0.0.1')
LOCAL_PORT=$(bashio::config 'local_port' '8123')
SUBDOMAIN=$(bashio::config 'subdomain' '')
CUSTOM_DOMAIN=$(bashio::config 'custom_domain' '')

# --- Validazioni minime ---
if [[ -z "${FRP_SERVER_ADDR}" || -z "${FRP_SHARED_TOKEN}" ]]; then
  bashio::log.fatal "frp_server_addr e frp_shared_token sono obbligatori!"
  exit 1
fi

# --- Calcolo NAMESPACE per FRP (user=...) ---
NAMESPACE="${SUBDOMAIN:-}"
if [[ -z "$NAMESPACE" && -n "${CUSTOM_DOMAIN:-}" ]]; then
  NAMESPACE="${CUSTOM_DOMAIN%%.*}"
fi
if [[ -z "$NAMESPACE" ]]; then
  NAMESPACE="$(hostname)"
fi

# --- Genero configurazione TOML per frpc ---
bashio::log.info "Generazione configurazione frpc.toml..."

CONFIG_PATH="/data/frpc.toml"

cat > "${CONFIG_PATH}" <<EOF
serverAddr = "${FRP_SERVER_ADDR}"
serverPort = ${FRP_SERVER_PORT}
auth.method = "token"
auth.token = "${FRP_SHARED_TOKEN}"
transport.tls.enable = true
user = "${NAMESPACE}"

[[proxies]]
name = "homeassistant"
type = "http"
localIP = "${LOCAL_IP}"
localPort = ${LOCAL_PORT}
EOF

if [[ -n "${CUSTOM_DOMAIN}" ]]; then
  echo "customDomains = [\"${CUSTOM_DOMAIN}\"]" >> "${CONFIG_PATH}"
elif [[ -n "${SUBDOMAIN}" ]]; then
  echo "subdomain = \"${SUBDOMAIN}\"" >> "${CONFIG_PATH}"
fi

bashio::log.info "Configurazione FRPC generata:"
sed 's/auth.token = .*/auth.token = "****"/g' "${CONFIG_PATH}" | sed 's/^/  /'
bashio::log.info "Namespace (user) impostato a: ${NAMESPACE}"

# --- Avvio frpc con watchdog ---
bashio::log.info "Avvio del servizio FRPC..."
SLEEP=5
while true; do
  /usr/bin/frpc -c "${CONFIG_PATH}"
  EC=$?
  bashio::log.warning "frpc terminato con codice ${EC}; nuovo tentativo tra ${SLEEP}s"
  sleep "${SLEEP}"
  if [ "${SLEEP}" -lt 60 ]; then
    SLEEP=$((SLEEP + 5))
  fi
done
