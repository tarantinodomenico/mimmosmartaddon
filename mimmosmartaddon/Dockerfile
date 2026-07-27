ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Installazione dipendenze
RUN apk add --no-cache curl tar ca-certificates bash jq

# Creazione della struttura nativa del servizio per s6-overlay v3
RUN mkdir -p /etc/s6-overlay/s6-rc.d/frpc \
    && mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d \
    && echo "longrun" > /etc/s6-overlay/s6-rc.d/frpc/type \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/frpc

# Copia e assegnazione permessi dello script
COPY run.sh /etc/s6-overlay/s6-rc.d/frpc/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/frpc/run
