FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG LIGHTHOUSE_VERSION

RUN case "$TARGETARCH" in \
      amd64) lighthouse_target='x86_64-unknown-linux-gnu' ;; \
      arm64) lighthouse_target='aarch64-unknown-linux-gnu' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/sigp/lighthouse/releases/download/v${LIGHTHOUSE_VERSION}/lighthouse-v${LIGHTHOUSE_VERSION}-${lighthouse_target}.tar.gz -o lighthouse.tar.gz \
    && tar -xvf lighthouse.tar.gz \
    && rm lighthouse.tar.gz \
    && mv lighthouse /usr/local/bin/ \
    && rm -rf /tmp/*

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
