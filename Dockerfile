ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Versione di FRP da installare
ENV FRP_VERSION=0.64.0

# Architettura target passata da Home Assistant durante il build
ARG BUILD_ARCH

# Installazione dipendenze e download del binario FRPC
RUN \
    set -x \
    && apk add --no-cache \
        curl \
        tar \
        ca-certificates \
    && case "${BUILD_ARCH}" in \
        aarch64) FRP_ARCH="linux_arm64" ;; \
        armv7|armhf) FRP_ARCH="linux_arm" ;; \
        i386) FRP_ARCH="linux_386" ;; \
        amd64) FRP_ARCH="linux_amd64" ;; \
        *) echo "Architettura non supportata: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && FRP_TGZ="frp_${FRP_VERSION}_${FRP_ARCH}.tar.gz" \
    && FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/${FRP_TGZ}" \
    && curl -fsSL -o "/tmp/${FRP_TGZ}" "${FRP_URL}" \
    && tar -xzf "/tmp/${FRP_TGZ}" -C /tmp \
    && mv "/tmp/frp_${FRP_VERSION}_${FRP_ARCH}/frpc" /usr/bin/frpc \
    && chmod +x /usr/bin/frpc \
    && rm -rf /tmp/*

# Copia dello script di avvio
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
