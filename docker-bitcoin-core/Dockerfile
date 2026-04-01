FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG BITCOIN_CORE_VERSION

RUN case "$TARGETARCH" in \
      amd64) bitcoin_core_target='x86_64-linux-gnu' ;; \
      arm64) bitcoin_core_target='aarch64-linux-gnu' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-${bitcoin_core_target}.tar.gz -o bitcoin.tar.gz \
    && tar -xvf bitcoin.tar.gz \
    && rm bitcoin.tar.gz \
    && mv bitcoin-*/bin/* /usr/local/bin/ \
    && mv bitcoin-*/share/* /usr/local/share/ \
    && rm -r bitcoin-* \
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
