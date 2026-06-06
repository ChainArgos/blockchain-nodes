# containerctl - Docker Compose Container Management

A modern CLI utility for managing Docker Compose containers with a focus on simplicity and visual feedback.

## Prerequisites

- [mise](https://mise.jdx.dev/) - Task runner and toolchain manager (recommended)
  ```bash
  brew install mise  # macOS
  # or
  curl https://mise.run | sh
  ```
- Rust toolchain (for development)
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```
- Docker and Docker Compose

## Usage

### Recommended: Using mise

The easiest way to manage containers is with `mise run` commands:

```bash
# Restart a container with log following
mise run restart ethereum-geth
mise run restart bitcoin-core

# Stop a container
mise run stop ethereum-geth
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

### Using mise (Recommended)

```bash
# Restart containers
mise run restart ethereum-geth
mise run restart bitcoin-core
mise run restart polygon-bor

# Stop containers
mise run stop ethereum-geth
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

## Available Commands

Run `mise tasks` to see all available container management commands. Here are some examples:

### Restart Commands
- `mise run restart arbitrum-one`
- `mise run restart avax-avalanchego`
- `mise run restart base-op-geth`
- `mise run restart base-op-node`
- `mise run restart berachain-beacon-kit`
- `mise run restart berachain-geth`
- `mise run restart bitcoin-core`
- `mise run restart bsc-geth`
- `mise run restart cardano-node`
- `mise run restart celo-geth`
- `mise run restart dogecoin-core`
- `mise run restart ethereum-geth`
- `mise run restart ethereum-lighthouse`
- `mise run restart polygon-bor`
- `mise run restart polygon-heimdall`
- And many more...

### Generic Commands
- `mise run restart <container-name>` - Restart any container
- `mise run stop <container-name>` - Stop any container

## Features

- **Color-coded output**: Clear visual feedback with colors and symbols
- **Progress indicators**: Shows what's happening at each step (⠿, ✓, ✗, →)
- **Error handling**: Exits immediately on errors with clear messages
- **Log following**: Optional `-f` flag to follow container logs after restart
- **Named commands**: Predefined commands for all containers via mise tasks

## Using with Cargo

For development or when mise is not available:

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

## Why Use mise?

mise tasks provide several benefits:

1. **Simple commands**: `mise run restart ethereum-geth` vs `./containerctl.rs restart ethereum-geth -f`
2. **Discoverability**: Run `mise tasks` to see all available commands
3. **Consistency**: All commands follow the same naming convention
4. **Integration**: Works seamlessly with build commands (`mise run build geth`)
5. **Documentation**: Each command has a description visible in `mise tasks`

## Supported Containers

The following containers have named restart commands via mise tasks:

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
