FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG KCC_GETH_VERSION

RUN cd /tmp \
    && curl -L https://github.com/kcc-community/kcc/releases/download/v${KCC_GETH_VERSION}-stable/geth -o geth \
    && mv geth /usr/local/bin/geth \
    && chmod -v u+x /usr/local/bin/geth \
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
