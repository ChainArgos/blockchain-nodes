FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG BERA_RETH_VERSION

RUN case "$TARGETARCH" in \
      amd64) reth_target='x86_64-unknown-linux-gnu' ;; \
      arm64) reth_target='aarch64-unknown-linux-gnu' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/berachain/bera-reth/releases/download/v${BERA_RETH_VERSION}/bera-reth-v${BERA_RETH_VERSION}-${reth_target}.tar.gz -o reth.tar.gz \
    && tar -xvf reth.tar.gz \
    && rm reth.tar.gz \
    && mv bera-reth /usr/local/bin/ \
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
