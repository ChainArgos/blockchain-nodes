FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG OMNICORE_VERSION

RUN case "$TARGETARCH" in \
      amd64) omnicore_target='x86_64-linux-gnu' ;; \
      arm64) omnicore_target='aarch64-linux-gnu' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/OmniLayer/omnicore/releases/download/v${OMNICORE_VERSION}/omnicore-${OMNICORE_VERSION}-${omnicore_target}.tar.gz -o omnicore.tar.gz \
    && tar -xvf omnicore.tar.gz \
    && rm omnicore.tar.gz \
    && mv omnicore-*/bin/* /usr/local/bin/ \
    && mv omnicore-*/include/* /usr/local/include/ \
    && mv omnicore-*/lib/* /usr/local/lib/ \
    && mv omnicore-*/share/* /usr/local/share/ \
    && rm -r omnicore-* \
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
