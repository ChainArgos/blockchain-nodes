FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG BSC_GETH_VERSION

RUN case "$TARGETARCH" in \
      amd64) geth_artifact='geth_linux' ;; \
      arm64) geth_artifact='geth-linux-arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && curl -L https://github.com/bnb-chain/bsc/releases/download/v${BSC_GETH_VERSION}/${geth_artifact} -o /usr/local/bin/geth \
    && chmod -v u+x /usr/local/bin/geth \
    && /usr/local/bin/geth --version

ADD config/config.toml /config/
ADD config/genesis.json /config/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
