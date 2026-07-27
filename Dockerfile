ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM ${BUILD_FROM}

# Installazione di pacchetti necessari (es. python3, bash, ecc.)
RUN apk add --no-cache python3 py3-pip bash

# Copia dei file di avvio
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
