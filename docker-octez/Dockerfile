FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH

RUN case "$TARGETARCH" in \
      amd64) package_file_id='166077302' ;; \
      arm64) package_file_id='166078371' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://gitlab.com/tezos/tezos/-/package_files/${package_file_id}/download -o octez.tar.gz \
    && tar -xvf octez.tar.gz \
    && rm octez.tar.gz \
    && mv octez-*/octez-node /usr/local/bin/ \
    && rm -rf octez-* \
    && chmod -v u+x /usr/local/bin/* \
    && rm -rf /tmp/*

RUN cd /tmp \
    && curl -L https://raw.githubusercontent.com/zcash/zcash/713fc761dd9cf4c9087c37b078bdeab98697bad2/zcutil/fetch-params.sh -o fetch-params.sh \
    && chmod +x fetch-params.sh \
    && ./fetch-params.sh \
    && rm fetch-params.sh \
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
