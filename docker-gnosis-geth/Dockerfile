FROM chainargos/debian-blockchain-build:1.1.0@sha256:12b8d0509e772abd9bccde40c49092fc028cbf10071a6b5cee2702240a163fb8 AS build

ARG GNOSIS_GETH_VERSION

RUN git clone --branch v${GNOSIS_GETH_VERSION} --single-branch --depth=1 https://github.com/gnosischain/go-ethereum.git

WORKDIR /go-ethereum

RUN make geth
# end build

FROM chainargos/debian-blockchain-base:1.1.0@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY --from=build /go-ethereum/build/bin/geth /usr/local/bin/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
