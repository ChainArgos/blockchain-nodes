# Blockchain Nodes

Modern Rust-based tooling for managing blockchain node Docker images and containers.

## Quick Start

### Prerequisites

```bash
# Install rust-script for running Rust scripts
cargo install rust-script

# Install Just command runner (optional but recommended)
brew install just  # macOS
# or
cargo install just
```

### Common Tasks

```bash
# List all available commands
just

# Build a Docker image
just build geth

# Restart a container
just restart-ethereum-geth

# Stop a container
just stop ethereum-geth
```

## Tools

This project includes three main Rust-based CLI tools:

### 1. build.rs - Docker Image Builder

Builds multi-platform Docker images for blockchain nodes.

```bash
# Build a package
./build.rs geth

# Dry run to see what would be executed
./build.rs geth --dry-run

# Or use Just
just build geth
just build-dry geth
```

**Features:**
- Multi-platform builds (amd64, arm64)
- Automatic manifest creation
- Color-coded output with progress indicators
- Configuration via simple TOML files

📖 [Full Documentation](BUILD_SYSTEM.md)

### 2. containerctl.rs - Container Management

Manages Docker Compose containers with restart and stop operations.

```bash
# Restart a container with log following
./containerctl.rs restart ethereum-geth -f

# Stop a container
./containerctl.rs stop ethereum-geth

# Or use Just
just restart ethereum-geth
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
just build geth
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
├── build.rs              # Docker image builder
├── containerctl.rs       # Container management tool
├── Justfile             # Just command runner recipes
├── Cargo.toml           # Rust dependencies
│
├── docker-*/            # Package directories
│   ├── build.toml       # Build configuration
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
version = "1.16.7-1"

[docker]
repository = "donbeave/geth"
platforms = ["amd64", "arm64"]
```

## Examples

### Building Images

```bash
# Build a single package
just build geth

# Build with custom docker args
./build.rs geth --extra-args "--progress auto"

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

### Multiple Operations

```bash
# Restart multiple containers
just restart-ethereum-geth restart-bitcoin-core
```

## Migration from Old Scripts

### build.sh → build.rs

**Before:**
```bash
cd docker-geth
./build.sh
```

**After:**
```bash
just build geth
# or
./build.rs geth
```

### restart-*.sh → Justfile

**Before:**
```bash
./restart-ethereum-geth.sh
./restart-bitcoin-core.sh
```

**After:**
```bash
just restart-ethereum-geth
just restart-bitcoin-core
```

### containerctl.main.kts → containerctl.rs

**Before:**
```bash
./containerctl.main.kts restart ethereum-geth -f
```

**After:**
```bash
./containerctl.rs restart ethereum-geth -f
# or
just restart ethereum-geth
```

## Features

✅ **Modern CLI** - Color-coded output with progress indicators  
✅ **Simplified commands** - Easy-to-remember Just recipes  
✅ **Multi-platform builds** - Support for amd64 and arm64  
✅ **Self-documenting** - Built-in help and command listings  
✅ **Error handling** - Clear error messages and proper exit codes  
✅ **Dry-run mode** - Preview commands before execution  
✅ **Configuration-driven** - Simple TOML configs per package  

## Development

### Running with Cargo

```bash
# Build system
cargo run --bin build -- geth

# Container control
cargo run --bin containerctl -- restart ethereum-geth -f
```

### Dependencies

All tools use:
- `anyhow` - Error handling
- `clap` - Command-line argument parsing
- `owo-colors` - Terminal colors
- `serde` & `toml` - Configuration parsing (build.rs only)

## Supported Blockchain Nodes

- Arbitrum
- Avalanche
- Base
- Berachain
- Bitcoin
- BSC (Binance Smart Chain)
- Cardano
- Celo
- Dogecoin
- Ethereum (Geth + Lighthouse)
- HECO
- Ink
- KCC
- Linea
- Litecoin
- Optimism
- Polygon
- Ronin
- Scroll
- Sonic
- Tezos
- Tron
- Unichain
- WBT
- Worldchain

## License

See LICENSE file for details.
