FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG AVALANCHEGO_VERSION

RUN case "$TARGETARCH" in \
      amd64) avalanchego_arch='amd64' ;; \
      arm64) avalanchego_arch='arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/ava-labs/avalanchego/releases/download/v${AVALANCHEGO_VERSION}/avalanchego-linux-${avalanchego_arch}-v${AVALANCHEGO_VERSION}.tar.gz -o avalanchego.tar.gz \
    && tar -xvf avalanchego.tar.gz \
    && rm avalanchego.tar.gz \
    && mv avalanchego-v${AVALANCHEGO_VERSION}/avalanchego /usr/local/bin/avalanchego \
    && rm -rf avalanchego-v${AVALANCHEGO_VERSION} \
    && chmod -v u+x /usr/local/bin/avalanchego \
    && rm -rf /tmp/*

ADD config /config/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
