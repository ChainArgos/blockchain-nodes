# Blockchain Nodes

Modern Rust-based tooling for managing blockchain node Docker images and containers.

## Quick Start

### Prerequisites

```bash
# Install Just command runner
brew install just  # macOS
# or
cargo install just

# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Common Tasks

```bash
# List all available commands
just

# Build a Docker image
just build geth

# Build all images
just build-all

# Restart a container
just restart-ethereum-geth

# Stop a container
just stop ethereum-geth
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

# Or use Just (recommended)
just build geth
just build-dry geth
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

# Or use Just (recommended)
just restart-ethereum-geth
just stop ethereum-geth
```

**Features:**
- Pull latest images
- Graceful container restarts
- Optional log following
- Modern CLI with visual feedback

📖 [Full Documentation](CONTAINERCTL.md)

### 3. Justfile - Command Runner

Simplifies common tasks with memorable commands.

```bash
# See all available commands
just

# Use named commands
just restart-ethereum-geth
just restart-bitcoin-core
just build-geth
just build-all
```

**Benefits:**
- Simple, memorable commands
- Self-documenting (just --list)
- Tab completion support
- All commands in one place

📖 [Full Documentation](JUSTFILE.md)

## Project Structure

```
blockchain-nodes/
├── docker-build.rs      # Docker image builder
├── containerctl.rs      # Container management tool
├── Justfile            # Just command runner recipes
├── Cargo.toml          # Rust project configuration
│
├── docker-*/           # Package directories
│   ├── build.toml      # Build configuration
│   ├── Dockerfile.amd64 # AMD64 Dockerfile
│   └── Dockerfile.arm64 # ARM64 Dockerfile
│
└── docs/
    ├── BUILD_SYSTEM.md  # Build system documentation
    ├── CONTAINERCTL.md  # Container management docs
    └── JUSTFILE.md      # Just command runner docs
```

## Configuration

Each package has a `build.toml` configuration file:

```toml
[package]
name = "geth"
version = "1.16.7"
build = "1"

[docker]
repository = "donbeave/geth"
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
# Build with named commands
just build-geth
just build-bitcoin-core
just build-arbitrum

# Build with generic command
just build geth

# Build all images
just build-all

# Dry run to preview commands
just build-dry geth
```

### Managing Containers

```bash
# Restart and follow logs
just restart-ethereum-geth

# Generic restart command
just restart ethereum-geth

# Stop a container
just stop ethereum-geth
```

## CI/CD Integration

The project uses GitHub Actions for automated builds with:
- Rust toolchain setup via `dtolnay/rust-toolchain`
- Rust dependency caching via `Swatinem/rust-cache`
- Just command runner via `extractions/setup-just`
- Reusable workflow for all builds (70% less code duplication)

## Features

✅ **Modern CLI** - Color-coded output with progress indicators  
✅ **Simplified commands** - Easy-to-remember Just recipes  
✅ **Multi-platform builds** - Support for amd64 and arm64  
✅ **Self-documenting** - Built-in help and command listings  
✅ **Error handling** - Clear error messages and proper exit codes  
✅ **Dry-run mode** - Preview commands before execution  
✅ **Configuration-driven** - Simple TOML configs per package  
✅ **Version management** - Separate version and build numbers  
✅ **Build argument automation** - Auto-generated from package names  

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

- Arbitrum
- Avalanche
- Beacon Kit (Berachain)
- Berachain (Reth)
- Bitcoin
- Bor (Polygon)
- BSC (Binance Smart Chain)
- Cardano
- Celo
- Dogecoin
- EigenDA Proxy
- Ethereum (Geth + Lighthouse)
- HECO
- Heimdall (Polygon)
- KCC
- Litecoin
- Octez (Tezos)
- Omni Core
- Optimism (OP Geth + OP Node)
- Celo OP Stack (OP Geth + OP Node)
- Ronin
- Scroll
- Sonic
- Tron
- WBT

## License

See LICENSE file for details.
