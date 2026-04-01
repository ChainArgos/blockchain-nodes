FROM chainargos/debian-blockchain-base:1.1.0@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG LITECOIN_CORE_VERSION

RUN case "$TARGETARCH" in \
      amd64) litecoin_target='x86_64-linux-gnu' ;; \
      arm64) litecoin_target='aarch64-linux-gnu' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/litecoin-project/litecoin/releases/download/v${LITECOIN_CORE_VERSION}/litecoin-${LITECOIN_CORE_VERSION}-${litecoin_target}.tar.gz -o litecoin.tar.gz \
    && tar -xvf litecoin.tar.gz \
    && rm litecoin.tar.gz \
    && mv litecoin-*/bin/* /usr/local/bin/ \
    && mv litecoin-*/share/* /usr/local/share/ \
    && rm -r litecoin-* \
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
