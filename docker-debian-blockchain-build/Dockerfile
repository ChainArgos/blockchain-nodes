FROM chainargos/debian-blockchain-base:1.0.0-1@sha256:20016fb614286d576b13da7673fa9c256b25f04afe791a5856511160b2ad47b7 AS build

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
