# containerctl - Docker Compose Container Management

A modern CLI utility for managing Docker Compose containers with a focus on simplicity and visual feedback.

## Prerequisites

- [Just](https://just.systems/) - Command runner (recommended)
  ```bash
  brew install just  # macOS
  # or
  cargo install just
  ```
- Rust toolchain (for development)
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```
- Docker and Docker Compose

## Usage

### Recommended: Using Just

The easiest way to manage containers is with `just` commands:

```bash
# Restart a container with log following
just restart-ethereum-geth
just restart-bitcoin-core

# Restart with generic command
just restart ethereum-geth

# Stop a container
just stop ethereum-geth
```

### Alternative: Direct Script Execution

You can also run the containerctl script directly:

```bash
# Restart a container
./containerctl.rs restart ethereum-geth

# Restart with log following
./containerctl.rs restart ethereum-geth --follow
# or
./containerctl.rs restart ethereum-geth -f

# Stop a container
./containerctl.rs stop ethereum-geth
```

## Commands

### restart

Performs the following steps:
1. Pulls the latest image (`docker compose pull <name>`)
2. Stops the container (`docker compose down <name>`)
3. Starts the container (`docker compose up -d <name>`)
4. Optionally follows logs (`docker logs -f <name>`)

Options:
- `-f, --follow`: Follow startup logs after restart

### stop

Stops a running container:
- Runs `docker compose down <name>`

## Examples

### Using Just (Recommended)

```bash
# Restart containers
just restart-ethereum-geth
just restart-bitcoin-core
just restart-polygon-bor

# Stop containers
just stop ethereum-geth
```

### Using Direct Script

```bash
# Restart a container
./containerctl.rs restart geth

# Restart and follow logs
./containerctl.rs restart geth -f

# Stop a container
./containerctl.rs stop geth
```

## Available Named Commands

Run `just --list` to see all available container management commands. Here are some examples:

### Restart Commands
- `just restart-arbitrum-one`
- `just restart-avax-avalanchego`
- `just restart-base-op-geth`
- `just restart-base-op-node`
- `just restart-berachain-beacon-kit`
- `just restart-berachain-geth`
- `just restart-bitcoin-core`
- `just restart-bsc-geth`
- `just restart-cardano-node`
- `just restart-celo-geth`
- `just restart-dogecoin-core`
- `just restart-ethereum-geth`
- `just restart-ethereum-lighthouse`
- `just restart-polygon-bor`
- `just restart-polygon-heimdall`
- And many more...

### Generic Commands
- `just restart <container-name>` - Restart any container
- `just stop <container-name>` - Stop any container

## Features

- **Color-coded output**: Clear visual feedback with colors and symbols
- **Progress indicators**: Shows what's happening at each step (⠿, ✓, ✗, →)
- **Error handling**: Exits immediately on errors with clear messages
- **Log following**: Optional `-f` flag to follow container logs after restart
- **Named commands**: Predefined commands for all containers via Justfile

## Using with Cargo

For development or when Just is not available:

```bash
# Run with cargo
cargo run --bin containerctl -- restart ethereum-geth
cargo run --bin containerctl -- stop ethereum-geth

# Build the binary
cargo build --release --bin containerctl
```

## Output Examples

### Restart Command

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Restarting container: ethereum-geth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Pulling latest image...
  ⠿ docker compose pull ethereum-geth
  ✓ Image pulled

→ Stopping container...
  ⠿ docker compose down ethereum-geth
  ✓ Container stopped

→ Starting container...
  ⠿ docker compose up -d ethereum-geth
  ✓ Container started

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Restart completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Stop Command

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stopping container: ethereum-geth
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

→ Stopping container...
  ⠿ docker compose down ethereum-geth
  ✓ Container stopped

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Stop completed successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Why Use Just?

The Justfile provides several benefits:

1. **Simple commands**: `just restart-ethereum-geth` vs `./containerctl.rs restart ethereum-geth -f`
2. **Discoverability**: Run `just --list` to see all available commands
3. **Consistency**: All commands follow the same naming convention
4. **Integration**: Works seamlessly with build commands (`just build-geth`)
5. **Documentation**: Each command has a description visible in `just --list`

## Supported Containers

The following containers have named restart commands in the Justfile:

- Arbitrum (arbitrum-one)
- Avalanche (avax-avalanchego)
- Base (base-op-geth, base-op-node)
- Berachain (berachain-beacon-kit, berachain-geth)
- Bitcoin (bitcoin-core)
- BSC (bsc-geth)
- Cardano (cardano-node)
- Celo (celo-geth, celo-op-geth, celo-op-node, celo-eigenda-proxy)
- Dogecoin (dogecoin-core)
- Ethereum (ethereum-geth, ethereum-lighthouse)
- HECO (heco-geth)
- Ink (ink-op-geth, ink-op-node)
- KCC (kcc-geth)
- Linea (linea-geth)
- Litecoin (litecoin-core)
- Optimism (optimism-op-geth, optimism-op-node)
- Polygon (polygon-bor, polygon-heimdall)
- Ronin (ronin-geth)
- Scroll (scroll-geth)
- Sonic (sonic-geth)
- Tezos (tezos-octez-node)
- Tron (tron-java)
- Unichain (unichain-op-geth, unichain-op-node)
- WBT (wbt-geth)
- Worldchain (worldchain-op-geth, worldchain-op-node)
