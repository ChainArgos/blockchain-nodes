FROM chainargos/debian-blockchain-build:1.1.0@sha256:12b8d0509e772abd9bccde40c49092fc028cbf10071a6b5cee2702240a163fb8 AS build

ARG TARGETARCH
ARG HEIMDALL_VERSION

RUN git clone --branch v${HEIMDALL_VERSION} --single-branch --depth=1 https://github.com/0xPolygon/heimdall-v2.git

WORKDIR /heimdall-v2

RUN case "$TARGETARCH" in \
      amd64) make_target='build' ;; \
      arm64) make_target='build-arm' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && make ${make_target}
# end build

FROM chainargos/debian-blockchain-base:1.1.0@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY --from=build /heimdall-v2/build/heimdalld /usr/local/bin/

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
