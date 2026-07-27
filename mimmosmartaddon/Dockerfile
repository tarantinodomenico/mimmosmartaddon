ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Dipendenze
RUN apk add --no-cache curl tar ca-certificates bash jq

# Copia dello script
COPY run.sh /
RUN chmod a+x /run.sh

# Configurazione Entrypoint corretta per s6-overlay v3
ENTRYPOINT ["/init"]
CMD ["/run.sh"]
