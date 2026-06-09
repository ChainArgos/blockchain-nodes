FROM chainargos/debian-blockchain-build:1.1.0@sha256:94254766acc9b144f5679f100594aa34e8b90f72883aa927110ccb4a642dfe28 AS build

RUN mise use -g --pin go@1.22.12

ARG TARGETARCH
ARG CELO_GETH_VERSION

RUN git clone --branch v${CELO_GETH_VERSION} --single-branch --depth=1 https://github.com/celo-org/celo-blockchain.git

WORKDIR /celo-blockchain

RUN case "$TARGETARCH" in \
      amd64) make_target='geth' ;; \
      arm64) make_target='geth-musl' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && make ${make_target}
# end build

FROM chainargos/debian-blockchain-base:1.1.0@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

COPY --from=build /celo-blockchain/build/bin/geth /usr/local/bin/

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
