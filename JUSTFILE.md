# Justfile - Command Runner for Blockchain Nodes

This project uses [Just](https://github.com/casey/just) as a command runner to simplify common tasks.

## Prerequisites

Install Just:

```bash
# macOS
brew install just

# or with cargo
cargo install just
```

## Usage

### List all available commands

```bash
just
# or
just --list
```

### Generic Commands

#### Restart any container with log following
```bash
just restart <container-name>
```

Example:
```bash
just restart ethereum-geth
```

#### Stop any container
```bash
just stop <container-name>
```

Example:
```bash
just stop ethereum-geth
```

#### Build a Docker image
```bash
just build <package-name>
```

Example:
```bash
just build geth
```

#### Build a Docker image (dry run)
```bash
just build-dry <package-name>
```

Example:
```bash
just build-dry geth
```

#### Build specific images with named commands

Each Docker image has a dedicated build command:

```bash
just build-geth
just build-bitcoin-core
just build-arbitrum
# ... etc
```

### Named Restart Commands

For convenience, each container has a dedicated restart command:

```bash
just restart-arbitrum-one
just restart-avax-avalanchego
just restart-base-op-geth
just restart-base-op-node
just restart-berachain-beacon-kit
just restart-berachain-geth
just restart-bitcoin-core
just restart-bsc-geth
just restart-cardano-node
just restart-celo-eigenda-proxy
just restart-celo-geth
just restart-celo-op-geth
just restart-celo-op-node
just restart-dogecoin-core
just restart-ethereum-geth
just restart-ethereum-lighthouse
just restart-heco-geth
just restart-ink-op-geth
just restart-ink-op-node
just restart-kcc-geth
just restart-linea-geth
just restart-litecoin-core
just restart-optimism-op-geth
just restart-optimism-op-node
just restart-polygon-bor
just restart-polygon-heimdall
just restart-ronin-geth
just restart-scroll-geth
just restart-sonic-geth
just restart-tezos-octez-node
just restart-tron-java
just restart-unichain-op-geth
just restart-unichain-op-node
just restart-wbt-geth
just restart-worldchain-op-geth
just restart-worldchain-op-node
```

## Migration from Shell Scripts

### Old way:
```bash
./restart-ethereum-geth.sh
./restart-bitcoin-core.sh
```

### New way:
```bash
just restart-ethereum-geth
just restart-bitcoin-core
```

## Available Build Commands

```bash
just build-arbitrum
just build-avalanchego
just build-beacon-kit
just build-bera-geth
just build-bitcoin-core
just build-bor
just build-bsc-geth
just build-cardano-node
just build-celo-geth
just build-celo-op-geth
just build-celo-op-node
just build-debian-blockchain-base
just build-debian-blockchain-build
just build-dogecoin-core
just build-eigenda-proxy
just build-geth
just build-heco-geth
just build-heimdall
just build-kcc-geth
just build-lighthouse
just build-litecoin-core
just build-octez
just build-op-geth
just build-op-node
just build-ronin-geth
just build-scroll-geth
just build-sonic-geth
just build-tron-java
just build-wbt-geth
```

## Examples

```bash
# List all commands
just

# Build Docker images
just build-geth
just build-bitcoin-core

# Build with generic command
just build geth

# Dry run build
just build-dry geth

# Restart Ethereum node
just restart-ethereum-geth

# Restart with generic command
just restart ethereum-geth

# Stop a container
just stop ethereum-geth
```

## Benefits of Using Just

1. **Simpler syntax**: `just restart-ethereum-geth` vs `./restart-ethereum-geth.sh`
2. **Self-documenting**: `just --list` shows all available commands with descriptions
3. **Tab completion**: Many shells support tab completion for Just commands
4. **Cross-platform**: Works on macOS, Linux, and Windows
5. **Centralized**: All commands in one file instead of scattered scripts
6. **Easy to maintain**: Add/modify commands in one place

## Advanced Usage

### Run multiple commands
```bash
just restart-ethereum-geth restart-bitcoin-core
```

### See what a recipe does
```bash
just --show restart-ethereum-geth
```

### Dry run (show what would be executed)
```bash
just --dry-run restart-ethereum-geth
```
