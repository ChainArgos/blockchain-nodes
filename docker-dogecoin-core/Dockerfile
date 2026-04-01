FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG DOGECOIN_CORE_VERSION

RUN case "$TARGETARCH" in \
      amd64) dogecoin_target='x86_64-linux-gnu' ;; \
      arm64) dogecoin_target='aarch64-linux-gnu' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/dogecoin/dogecoin/releases/download/v${DOGECOIN_CORE_VERSION}/dogecoin-${DOGECOIN_CORE_VERSION}-${dogecoin_target}.tar.gz -o dogecoin.tar.gz \
    && tar -xvf dogecoin.tar.gz \
    && rm dogecoin.tar.gz \
    && mv dogecoin-*/bin/* /usr/local/bin/ \
    && mv dogecoin-*/include/* /usr/local/include/ \
    && mv dogecoin-*/lib/* /usr/local/lib/ \
    && mv dogecoin-*/share/* /usr/local/share/ \
    && rm -r dogecoin-* \
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
