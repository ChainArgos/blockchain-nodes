# Blockchain Nodes Management

# List all available commands
default:
    @just --list

# Restart a container with log following
restart container:
    ./containerctl.rs restart {{container}} -f

# Stop a container
stop container:
    ./containerctl.rs stop {{container}}

# Build a Docker image
build package:
    ./build.rs {{package}}

# Build a Docker image (dry run)
build-dry package:
    ./build.rs {{package}} --dry-run

# Build Arbitrum Docker image
build-arbitrum:
    ./build.rs arbitrum

# Build Avalanchego Docker image
build-avalanchego:
    ./build.rs avalanchego

# Build Beacon Kit Docker image
build-beacon-kit:
    ./build.rs beacon-kit

# Build Bera Geth Docker image
build-bera-geth:
    ./build.rs bera-geth

# Build Bitcoin Core Docker image
build-bitcoin-core:
    ./build.rs bitcoin-core

# Build Bor Docker image
build-bor:
    ./build.rs bor

# Build BSC Geth Docker image
build-bsc-geth:
    ./build.rs bsc-geth

# Build Cardano Node Docker image
build-cardano-node:
    ./build.rs cardano-node

# Build Celo Geth Docker image
build-celo-geth:
    ./build.rs celo-geth

# Build Celo OP Geth Docker image
build-celo-op-geth:
    ./build.rs celo-op-geth

# Build Celo OP Node Docker image
build-celo-op-node:
    ./build.rs celo-op-node

# Build Debian Blockchain Base Docker image
build-debian-blockchain-base:
    ./build.rs debian-blockchain-base

# Build Debian Blockchain Build Docker image
build-debian-blockchain-build:
    ./build.rs debian-blockchain-build

# Build Dogecoin Core Docker image
build-dogecoin-core:
    ./build.rs dogecoin-core

# Build EigenDA Proxy Docker image
build-eigenda-proxy:
    ./build.rs eigenda-proxy

# Build Geth Docker image
build-geth:
    ./build.rs geth

# Build HECO Geth Docker image
build-heco-geth:
    ./build.rs heco-geth

# Build Heimdall Docker image
build-heimdall:
    ./build.rs heimdall

# Build KCC Geth Docker image
build-kcc-geth:
    ./build.rs kcc-geth

# Build Lighthouse Docker image
build-lighthouse:
    ./build.rs lighthouse

# Build Litecoin Core Docker image
build-litecoin-core:
    ./build.rs litecoin-core

# Build Octez Docker image
build-octez:
    ./build.rs octez

# Build OP Geth Docker image
build-op-geth:
    ./build.rs op-geth

# Build OP Node Docker image
build-op-node:
    ./build.rs op-node

# Build Ronin Geth Docker image
build-ronin-geth:
    ./build.rs ronin-geth

# Build Scroll Geth Docker image
build-scroll-geth:
    ./build.rs scroll-geth

# Build Sonic Geth Docker image
build-sonic-geth:
    ./build.rs sonic-geth

# Build Tron Java Docker image
build-tron-java:
    ./build.rs tron-java

# Build WBT Geth Docker image
build-wbt-geth:
    ./build.rs wbt-geth

# Restart Arbitrum One node
restart-arbitrum-one:
    ./containerctl.rs restart arbitrum-one -f

# Restart Avalanche node
restart-avax-avalanchego:
    ./containerctl.rs restart avax-avalanchego -f

# Restart Base OP Geth node
restart-base-op-geth:
    ./containerctl.rs restart base-op-geth -f

# Restart Base OP Node
restart-base-op-node:
    ./containerctl.rs restart base-op-node -f

# Restart Berachain Beacon Kit node
restart-berachain-beacon-kit:
    ./containerctl.rs restart berachain-beacon-kit -f

# Restart Berachain Geth node
restart-berachain-geth:
    ./containerctl.rs restart berachain-geth -f

# Restart Bitcoin Core node
restart-bitcoin-core:
    ./containerctl.rs restart bitcoin-core -f

# Restart BSC Geth node
restart-bsc-geth:
    ./containerctl.rs restart bsc-geth -f

# Restart Cardano node
restart-cardano-node:
    ./containerctl.rs restart cardano-node -f

# Restart Celo EigenDA Proxy
restart-celo-eigenda-proxy:
    ./containerctl.rs restart celo-eigenda-proxy -f

# Restart Celo Geth node
restart-celo-geth:
    ./containerctl.rs restart celo-geth -f

# Restart Celo OP Geth node
restart-celo-op-geth:
    ./containerctl.rs restart celo-op-geth -f

# Restart Celo OP Node
restart-celo-op-node:
    ./containerctl.rs restart celo-op-node -f

# Restart Dogecoin Core node
restart-dogecoin-core:
    ./containerctl.rs restart dogecoin-core -f

# Restart Ethereum Geth node
restart-ethereum-geth:
    ./containerctl.rs restart ethereum-geth -f

# Restart Ethereum Lighthouse node
restart-ethereum-lighthouse:
    ./containerctl.rs restart ethereum-lighthouse -f

# Restart HECO Geth node
restart-heco-geth:
    ./containerctl.rs restart heco-geth -f

# Restart Ink OP Geth node
restart-ink-op-geth:
    ./containerctl.rs restart ink-op-geth -f

# Restart Ink OP Node
restart-ink-op-node:
    ./containerctl.rs restart ink-op-node -f

# Restart KCC Geth node
restart-kcc-geth:
    ./containerctl.rs restart kcc-geth -f

# Restart Linea Geth node
restart-linea-geth:
    ./containerctl.rs restart linea-geth -f

# Restart Litecoin Core node
restart-litecoin-core:
    ./containerctl.rs restart litecoin-core -f

# Restart Optimism OP Geth node
restart-optimism-op-geth:
    ./containerctl.rs restart optimism-op-geth -f

# Restart Optimism OP Node
restart-optimism-op-node:
    ./containerctl.rs restart optimism-op-node -f

# Restart Polygon Bor node
restart-polygon-bor:
    ./containerctl.rs restart polygon-bor -f

# Restart Polygon Heimdall node
restart-polygon-heimdall:
    ./containerctl.rs restart polygon-heimdall -f

# Restart Ronin Geth node
restart-ronin-geth:
    ./containerctl.rs restart ronin-geth -f

# Restart Scroll Geth node
restart-scroll-geth:
    ./containerctl.rs restart scroll-geth -f

# Restart Sonic Geth node
restart-sonic-geth:
    ./containerctl.rs restart sonic-geth -f

# Restart Tezos Octez node
restart-tezos-octez-node:
    ./containerctl.rs restart tezos-octez-node -f

# Restart Tron Java node
restart-tron-java:
    ./containerctl.rs restart tron-java -f

# Restart Unichain OP Geth node
restart-unichain-op-geth:
    ./containerctl.rs restart unichain-op-geth -f

# Restart Unichain OP Node
restart-unichain-op-node:
    ./containerctl.rs restart unichain-op-node -f

# Restart WBT Geth node
restart-wbt-geth:
    ./containerctl.rs restart wbt-geth -f

# Restart Worldchain OP Geth node
restart-worldchain-op-geth:
    ./containerctl.rs restart worldchain-op-geth -f

# Restart Worldchain OP Node
restart-worldchain-op-node:
    ./containerctl.rs restart worldchain-op-node -f
