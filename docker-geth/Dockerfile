FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG GETH_VERSION
ARG GIT_COMMIT
ARG LEGACY_VERSION
ARG LEGACY_GIT_COMMIT

RUN case "$TARGETARCH" in \
      amd64) geth_arch='amd64' ;; \
      arm64) geth_arch='arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-${geth_arch}-${GETH_VERSION}-${GIT_COMMIT}.tar.gz -o geth.tar.gz \
    && tar -xvf geth.tar.gz \
    && rm geth.tar.gz \
    && rm geth-*/COPYING \
    && mv geth-*/* /usr/local/bin/ \
    && rm -r geth-* \
    && rm -rf /tmp/*

RUN case "$TARGETARCH" in \
      amd64) geth_arch='amd64' ;; \
      arm64) geth_arch='arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-${geth_arch}-${LEGACY_VERSION}-${LEGACY_GIT_COMMIT}.tar.gz -o geth.tar.gz \
    && tar -xvf geth.tar.gz \
    && rm geth.tar.gz \
    && rm geth-*/COPYING \
    && mv geth-* /opt/geth-1.13 \
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
