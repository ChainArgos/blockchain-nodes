#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

./docker-debian-blockchain-base/build.sh
./docker-debian-blockchain-build/build.sh
./docker-arbitrum/build.sh
./docker-avalanchego/build.sh
./docker-bitcoin-core/build.sh
./docker-bor/build.sh
./docker-bsc-geth/build.sh
./docker-cardano-node/build.sh
./docker-celo-geth/build.sh
./docker-dogecoin-core/build.sh
./docker-geth/build.sh
./docker-heco-geth/build.sh
./docker-heimdall/build.sh
./docker-kcc-geth/build.sh
./docker-lighthouse/build.sh
./docker-litecoin-core/build.sh
./docker-octez/build.sh
./docker-op-geth/build.sh
./docker-op-node/build.sh
./docker-ronin-geth/build.sh
./docker-scroll-geth/build.sh
./docker-tron-java/build.sh
./docker-wbt-geth/build.sh
