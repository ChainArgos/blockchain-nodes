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
mise run docker-build <package-name>
```

Example:
```bash
mise run docker-build geth
mise run docker-build bitcoin-core
```

#### Build a Docker image (dry run)
```bash
mise run docker-build-dry <package-name>
```

Example:
```bash
mise run docker-build-dry geth
```

#### Check if an image exists on Docker Hub
```bash
mise run exists <package-name>
mise run exists-verbose <package-name>
mise run exists-platform <package-name> <platform>
```

#### Build all images in sequence
```bash
mise run docker-build-all
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

## CI Gates

The CI lane (`ci-code.yml` via the generated `.github/workflows/ci.yml`) runs five
disjoint gates, each mapping to exactly one mise task. `ci` is a depends-only
aggregate of all five for local use; no gate command appears in more than one task.

```bash
mise run install   # mise install --locked (provision pinned tools)
mise run build     # cargo build --workspace --all-targets --locked
mise run test      # cargo nextest run --workspace --all-targets --locked
mise run lint      # cargo clippy --workspace --all-targets --locked -- -D warnings
mise run fmt       # cargo fmt --all -- --check
mise run ci        # depends-only aggregate of the five gates above
```

Docker image builds are operator tasks, not CI gates: `docker-build`, `docker-build-dry`, `docker-build-all`.

## Examples

```bash
# List all tasks
mise tasks

# Build Docker images
mise run docker-build geth
mise run docker-build bitcoin-core

# Dry run build
mise run docker-build-dry geth

# Build all images
mise run docker-build-all

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
