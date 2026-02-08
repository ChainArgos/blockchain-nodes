FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TRON_JAVA_VERSION

RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y --no-install-recommends \
                   libxi6 \
                   libxrender1 \
                   libxtst6 \
                   libasound2 \
                   libfreetype6 \
                   libfontconfig1 \
                   libgoogle-perftools4 \
        && apt-get autoremove -y \
        && rm -rf /var/lib/apt/* \
                  /var/cache/apt/* \
                  /tmp/*

ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4"
ENV TCMALLOC_RELEASE_RATE=10

RUN mise install java@liberica-8u482+10
RUN mise use -g --pin java@liberica-8u482+10

RUN curl -L https://github.com/tronprotocol/java-tron/releases/download/GreatVoyage-v${TRON_JAVA_VERSION}/FullNode.jar -o /FullNode.jar

ADD config /config/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data/tron-java
VOLUME /data
WORKDIR /data/tron-java

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
