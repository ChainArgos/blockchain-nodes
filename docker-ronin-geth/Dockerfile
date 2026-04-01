FROM chainargos/debian-blockchain-build:1.0.0@sha256:b4989a6d9564295dcf4ffd085fbcb717c176864b38054489bdb2b642a1e2b3a7 AS build

ARG RONIN_GETH_VERSION

RUN git clone --branch v${RONIN_GETH_VERSION} --single-branch --depth=1 https://github.com/ronin-chain/ronin.git

WORKDIR /ronin

RUN make ronin
# end build

FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

COPY --from=build /ronin/build/bin/ronin /usr/local/bin/
COPY --from=build /ronin/genesis/mainnet.json /config/

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
