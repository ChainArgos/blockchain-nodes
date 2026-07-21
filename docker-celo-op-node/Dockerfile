FROM chainargos/debian-blockchain-build:1.1.0@sha256:94254766acc9b144f5679f100594aa34e8b90f72883aa927110ccb4a642dfe28 AS build

ARG CELO_OP_NODE_VERSION

RUN git clone --branch celo-v${CELO_OP_NODE_VERSION} --single-branch --depth=1 https://github.com/celo-org/optimism.git

WORKDIR /optimism

RUN mise trust
RUN sed -i '/^asterisc = /d; /^kontrol = /d; /^binary_signer = /d' mise.toml
RUN --mount=type=secret,id=github_token,required=false \
    GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || true)" \
    MISE_PYTHON_GITHUB_ATTESTATIONS=false mise install

RUN make op-node
# end build

FROM chainargos/debian-blockchain-base:1.1.0@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY --from=build /optimism/op-node/bin/op-node /usr/local/bin/

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
