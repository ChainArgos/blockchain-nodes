FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG BEACON_KIT_VERSION

RUN cd /tmp \
    && curl -L https://github.com/berachain/beacon-kit/releases/download/v${BEACON_KIT_VERSION}/beacond-v${BEACON_KIT_VERSION}-linux-amd64.tar.gz -o beacond.tar.gz \
    && tar -xzvf beacond.tar.gz \
    && rm beacond.tar.gz \
    && mv beacond-* /usr/local/bin/beacond \
    && chmod a+x /usr/local/bin/beacond \
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
