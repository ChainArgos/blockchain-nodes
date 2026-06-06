# Blockchain Nodes

Modern Rust-based tooling for managing blockchain node Docker images and containers.

## Quick Start

### Prerequisites

```bash
# Install mise (manages Rust toolchain + task runner)
curl https://mise.run | sh

# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Common Tasks

```bash
# List all available commands
mise tasks

# Build a Docker image
mise run build geth

# Build all images
mise run build-all

# Restart a container
mise run restart ethereum-geth

# Stop a container
mise run stop ethereum-geth
```

## Tools

This project includes two main Rust-based CLI tools:

### 1. docker-build.rs - Docker Image Builder

Builds multi-platform Docker images for blockchain nodes.

```bash
# Build a package
./docker-build.rs geth

# Dry run to see what would be executed
./docker-build.rs geth --dry-run

# Or use mise (recommended)
mise run build geth
mise run build-dry geth
```

**Features:**
- Multi-platform builds (amd64, arm64)
- Automatic manifest creation
- Color-coded output with progress indicators
- Configuration via simple TOML files
- Dynamic version management with separate version and build fields

📖 [Full Documentation](BUILD_SYSTEM.md)

### 2. containerctl.rs - Container Management

Manages Docker Compose containers with restart and stop operations.

```bash
# Restart a container with log following
./containerctl.rs restart ethereum-geth -f

# Stop a container
./containerctl.rs stop ethereum-geth

# Or use mise (recommended)
mise run restart ethereum-geth
mise run stop ethereum-geth
```

**Features:**
- Pull latest images
- Graceful container restarts
- Optional log following
- Modern CLI with visual feedback

📖 [Full Documentation](CONTAINERCTL.md)

### 3. mise Tasks - Command Runner

Simplifies common tasks with memorable commands.

```bash
# See all available commands
mise tasks

# Use commands
mise run restart ethereum-geth
mise run restart bitcoin-core
mise run build geth
mise run build-all
```

**Benefits:**
- Simple, memorable commands
- Self-documenting (`mise tasks`)
- Tab completion support
- All commands in one place

📖 [Full Documentation](TASKS.md)

## Project Structure

```
blockchain-nodes/
├── docker-build.rs      # Docker image builder
├── containerctl.rs      # Container management tool
├── TASKS.md            # mise task runner documentation
├── Cargo.toml          # Rust project configuration
│
├── docker-*/           # Package directories
│   ├── build.toml      # Build configuration
│   └── Dockerfile      # Dockerfile used for every configured platform
│
└── docs/
    ├── BUILD_SYSTEM.md  # Build system documentation
    ├── CONTAINERCTL.md  # Container management docs
    └── TASKS.md         # mise task runner docs
```

## Configuration

Each package has a `build.toml` configuration file:

```toml
[package]
name = "geth"
version = "1.16.7"
build = "1"

[docker]
repository = "chainargos/geth"
platforms = ["amd64", "arm64"]
```

### Version Management

- `version` - Upstream software version (e.g., "1.16.7")
- `build` - Build number for packaging (e.g., "1")
- Docker tags use the full version: `{version}-{build}` (e.g., "1.16.7-1")
- Build arguments pass only the version to Dockerfiles

## Examples

### Building Images

```bash
# Build with generic command
mise run build geth
mise run build bitcoin-core
mise run build arbitrum

# Build all images
mise run build-all

# Dry run to preview commands
mise run build-dry geth
```

### Managing Containers

```bash
# Restart and follow logs
mise run restart ethereum-geth

# Stop a container
mise run stop ethereum-geth
```

## Development

### Running with Cargo

```bash
# Build system
cargo run --bin docker-build -- geth

# Container control
cargo run --bin containerctl -- restart ethereum-geth -f
```

### Building the Project

```bash
# Build all binaries
cargo build --release

# Run tests
cargo test

# Build specific binary
cargo build --bin docker-build --release
cargo build --bin containerctl --release
```

### Dependencies

All tools use:
- `anyhow` - Error handling
- `clap` - Command-line argument parsing
- `owo-colors` - Terminal colors
- `serde` & `toml` - Configuration parsing (docker-build.rs only)

## Supported Blockchain Nodes

- Arbitrum One
- Avalanche
- Base (OP Stack)
- Berachain (Beacon Kit + Reth)
- Bitcoin Cash
- Bitcoin Core
- BSC (Binance Smart Chain)
- Cardano
- Celo (Geth + OP Stack + EigenDA Proxy)
- Dogecoin
- Ethereum (Geth + Lighthouse)
- Gnosis (Geth + Lighthouse)
- HECO
- Ink (OP Stack)
- KCC
- Linea
- Litecoin
- Omni Core
- Optimism (OP Stack)
- Polygon (Bor + Heimdall)
- Ronin
- Scroll
- Sonic
- Tezos (Octez)
- Tron
- Unichain (OP Stack)
- WBT
- Worldchain (OP Stack)

## License

See LICENSE file for details.
