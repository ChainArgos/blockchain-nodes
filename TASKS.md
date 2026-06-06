# Tasks - Command Runner for Blockchain Nodes

This project uses [mise](https://mise.jdx.dev/) as both a tool version manager and a task runner.

## Prerequisites

Install mise:

```bash
# macOS
brew install mise

# or via installer
curl https://mise.run | sh
```

mise is also required to run `docker-build.rs` and `containerctl.rs` (it manages `rust-script`).

## Usage

### List all available tasks

```bash
mise tasks
```

### Generic Commands

#### Build a Docker image
```bash
mise run build <package-name>
```

Example:
```bash
mise run build geth
mise run build bitcoin-core
```

#### Build a Docker image (dry run)
```bash
mise run build-dry <package-name>
```

Example:
```bash
mise run build-dry geth
```

#### Check if an image exists on Docker Hub
```bash
mise run exists <package-name>
mise run exists-verbose <package-name>
mise run exists-platform <package-name> <platform>
```

#### Build all images in sequence
```bash
mise run build-all
```

#### Restart a container with log following
```bash
mise run restart <container-name>
```

Example:
```bash
mise run restart ethereum-geth
mise run restart arbitrum-one
```

#### Stop a container
```bash
mise run stop <container-name>
```

Example:
```bash
mise run stop ethereum-geth
```

## Examples

```bash
# List all tasks
mise tasks

# Build Docker images
mise run build geth
mise run build bitcoin-core

# Dry run build
mise run build-dry geth

# Build all images
mise run build-all

# Restart Ethereum node
mise run restart ethereum-geth

# Stop a container
mise run stop ethereum-geth

# Check if image exists
mise run exists geth
mise run exists-platform geth amd64
```

## Alternative: Direct Script Execution

All tasks are thin wrappers around the Rust scripts. You can invoke them directly:

```bash
./docker-build.rs geth
./docker-build.rs geth --dry-run
./docker-exists.rs geth
./containerctl.rs restart ethereum-geth -f
./containerctl.rs stop ethereum-geth
```
