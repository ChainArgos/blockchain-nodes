# Build System

This project uses a Rust-based build system to build Docker images for blockchain nodes.

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
- Docker with buildx support
- Docker registry access (for pushing images)

## Configuration

Each package directory contains a `build.toml` file with the following structure:

```toml
[package]
name = "geth"
version = "1.16.7"
build = "1"

[docker]
repository = "donbeave/geth"
platforms = ["amd64", "arm64"]
```

### Configuration Fields

- `package.name`: The package name (e.g., "geth")
- `package.version`: The upstream software version (e.g., "1.16.7")
- `package.build`: The build number for this version (e.g., "1")
- `docker.repository`: The Docker repository (e.g., "donbeave/geth")
- `docker.platforms`: List of platforms to build for (e.g., ["amd64", "arm64"])

### Version Management

The build system uses separate `version` and `build` fields:

- **version**: Upstream software version (passed to Dockerfile as build arg)
- **build**: Your build/packaging version
- **Full version**: `{version}-{build}` used for Docker tags (e.g., "1.16.7-1")

Example:
- `version = "1.16.7"` + `build = "1"` → Docker tag: `donbeave/geth:1.16.7-1`
- Build argument passed to Dockerfile: `GETH_VERSION=1.16.7`

## Directory Structure

Each package should have the following structure:

```
docker-<package>/
├── build.toml
├── Dockerfile.amd64
└── Dockerfile.arm64
```

For single-platform builds, only include the relevant Dockerfile (e.g., only `Dockerfile.amd64`).

## Usage

### Recommended: Using Just

The easiest way to build images is with `just` commands:

```bash
# Build a specific package
just build geth

# Build with dry-run
just build-dry geth

# Build all packages
just build-all

# Build using named commands
just build-geth
just build-bitcoin-core
just build-arbitrum
```

### Alternative: Direct Script Execution

You can also run the build script directly:

```bash
# Build a package
./docker-build.rs geth

# Dry run to see what would be executed
./docker-build.rs geth --dry-run
```

### Build Options

- `PACKAGE`: Package name to build (e.g., "geth", "bitcoin-core")
- `--extra-args <ARGS>` or `-e <ARGS>`: Extra arguments to pass to docker buildx build (default: "--progress plain")
- `--dry-run` or `-n`: Show what would be executed without running
- `--help` or `-h`: Show help message

### Examples

```bash
# Build packages (recommended - using just)
just build geth
just build bitcoin-core
just build-all

# Build with custom progress output (direct script)
./docker-build.rs geth --extra-args "--progress auto"

# Dry run to see commands (both methods work)
just build-dry geth
./docker-build.rs geth --dry-run

# Build with GITHUB_TOKEN (for packages that need it)
GITHUB_TOKEN=your_token just build op-node
```

## Build Process

The build script performs the following steps:

1. Reads the `build.toml` configuration file
2. Generates the build argument name from package name (e.g., "geth" → "GETH_VERSION")
3. For each platform in `platforms`:
   - Builds the Docker image using `Dockerfile.<platform>`
   - Passes version as build argument (e.g., `--build-arg GETH_VERSION=1.16.7`)
   - Tags it as `<repository>:<version>-<build>-<platform>` (e.g., `donbeave/geth:1.16.7-1-amd64`)
   - Pushes it to the registry
4. If multiple platforms are configured:
   - Creates a multi-platform manifest tagged as `<repository>:<version>-<build>`
   - Pushes the manifest to the registry

## Build Argument Naming Convention

Build arguments are automatically generated from the package name:

- Package: `geth` → Arg: `GETH_VERSION`
- Package: `bitcoin-core` → Arg: `BITCOIN_CORE_VERSION`
- Package: `op-geth` → Arg: `OP_GETH_VERSION`
- Package: `wbt-geth` → Arg: `WBT_GETH_VERSION`

The version (without build number) is passed as the argument value.

## Using with Cargo

For development or when Just is not available:

```bash
# Run with cargo
cargo run --bin docker-build -- geth

# Dry run
cargo run --bin docker-build -- geth --dry-run

# Build the binary
cargo build --release --bin docker-build
```

## Environment Variables

- `GITHUB_TOKEN`: Automatically passed as a build argument if set (used by some packages like op-node)

## Available Packages

Run `just --list` to see all available build commands, or build any of these packages:

- arbitrum, avalanchego, beacon-kit, bera-geth
- bitcoin-core, bor, bsc-geth, cardano-node
- celo-geth, celo-op-geth, celo-op-node
- debian-blockchain-base, debian-blockchain-build
- dogecoin-core, eigenda-proxy
- geth, heco-geth, heimdall, kcc-geth
- lighthouse, litecoin-core, octez
- op-geth, op-node, ronin-geth
- scroll-geth, sonic-geth, tron-java, wbt-geth

## Notes

- All builds use `--pull` to ensure base images are up to date
- All builds use `--push` to push directly to the registry
- All builds use `--provenance=false` to disable provenance attestation
- Platform prefix `linux/` is automatically added (you only specify `amd64`, `arm64`, etc.)
- Build arguments are generated automatically from package names

## Troubleshooting

### Build fails with "binary target name conflicts"

Make sure your Cargo.toml doesn't have a binary named `build` - use `docker-build` instead.

### Version not being passed to Dockerfile

Check that your `build.toml` has both `version` and `build` fields set. The version field should not include the build number.

### Build argument not recognized in Dockerfile

Ensure your Dockerfile has an `ARG` declaration matching the auto-generated name. For example, for package `geth`, your Dockerfile should have:
```dockerfile
ARG GETH_VERSION
RUN echo "Building version ${GETH_VERSION}"
```
