ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Installazione dipendenze
RUN apk add --no-cache curl tar ca-certificates bash jq

# Copia dello script di avvio direttamente nella radice
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
