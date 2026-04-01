FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8 AS build

ARG TARGETARCH

RUN case "$TARGETARCH" in \
      amd64) apt_packages='build-essential linux-headers-amd64 git' ;; \
      arm64) apt_packages='build-essential linux-headers-arm64 musl-dev git' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends ${apt_packages} \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/* \
              /var/cache/apt/* \
              /tmp/*

RUN mise install go@1.22.12
RUN mise install go@1.25.3

RUN mise use -g --pin go@1.25.3
