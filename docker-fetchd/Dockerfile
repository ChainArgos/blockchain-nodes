FROM chainargos/debian-blockchain-build:1.0.0@sha256:b4989a6d9564295dcf4ffd085fbcb717c176864b38054489bdb2b642a1e2b3a7 AS build

ARG FETCHD_VERSION

RUN mise use -g --pin go@1.18.10

RUN git clone --branch v${FETCHD_VERSION} --single-branch --depth=1 https://github.com/fetchai/fetchd.git

WORKDIR /fetchd

RUN make install
RUN make build

RUN ARCH=`uname -m` && GOMODCACHE=$(go env GOMODCACHE) && cp ${GOMODCACHE}/github.com/\!cosm\!wasm/wasmvm@v1.0.1/api/libwasmvm.${ARCH}.so /usr/lib/libwasmvm.${ARCH}.so
# end build

FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

RUN apt-get update \
    && apt-get install -y --no-install-recommends aria2 \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/* /var/cache/apt/* /tmp/*

COPY --from=build /usr/lib/libwasmvm.*.so /usr/lib/
COPY --from=build /fetchd/build/fetchd /usr/local/bin/

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
