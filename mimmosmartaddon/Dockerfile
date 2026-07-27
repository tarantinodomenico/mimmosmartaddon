ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Dipendenze
RUN apk add --no-cache curl tar ca-certificates bash jq

# Creiamo la struttura di servizio nativa per s6-overlay v3
RUN mkdir -p /etc/s6-overlay/s6-rc.d/frpc \
    && mkdir -p /etc/s6-overlay/s6-rc.d/user/contents.d

# Definizione del servizio di tipo longrun
RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/frpc/type \
    && touch /etc/s6-overlay/s6-rc.d/user/contents.d/frpc

# Copia dello script di avvio come eseguibile del servizio s6
COPY run.sh /etc/s6-overlay/s6-rc.d/frpc/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/frpc/run
