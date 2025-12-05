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
