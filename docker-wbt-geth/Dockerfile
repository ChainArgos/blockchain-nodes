FROM chainargos/debian-blockchain-build:1.0.0@sha256:b4989a6d9564295dcf4ffd085fbcb717c176864b38054489bdb2b642a1e2b3a7 AS build

RUN mise use -g --pin go@1.22.12

ARG WBT_GETH_VERSION

RUN git clone --branch v${WBT_GETH_VERSION} --single-branch --depth=1 https://github.com/whitebit-exchange/wbt.git

WORKDIR /wbt

RUN make all
# end build

FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY --from=build /wbt/build/bin/geth /usr/local/bin/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
