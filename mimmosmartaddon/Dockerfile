ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Dipendenze necessarie per bashio e download
RUN apk add --no-cache \
    curl \
    jq \
    tar \
    ca-certificates

# Copia e configura lo script di avvio nella cartella di s6
COPY run.sh /etc/services.d/frpc/run
RUN chmod a+x /etc/services.d/frpc/run
