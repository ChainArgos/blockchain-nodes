FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG CARDANO_NODE_VERSION

RUN case "$TARGETARCH" in \
      amd64) cardano_node_arch='amd64' ;; \
      arm64) cardano_node_arch='arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/IntersectMBO/cardano-node/releases/download/${CARDANO_NODE_VERSION}/cardano-node-${CARDANO_NODE_VERSION}-linux-${cardano_node_arch}.tar.gz -o cardano-node.tar.gz \
    && tar -xvf cardano-node.tar.gz \
    && rm cardano-node.tar.gz \
    && mv share/mainnet /etc/cardano-node \
    && chmod -v u+x bin/* \
    && mv bin/* /usr/local/bin/ \
    && rm -rf bin \
    && rm -rf share \
    && rm -rf /tmp/*

RUN sed -i 's/"TraceBlockFetchDecisions": false/"TraceBlockFetchDecisions": true/g' /etc/cardano-node/config.json

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
