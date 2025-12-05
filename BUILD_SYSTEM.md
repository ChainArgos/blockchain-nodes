# Build System

This project uses a Rust-based build system to build Docker images for blockchain nodes.

## Prerequisites

- [rust-script](https://rust-script.org/) - Install with: `cargo install rust-script`
- Docker with buildx support
- Docker registry access (for pushing images)

## Configuration

Each package directory contains a `build.toml` file with the following structure:

```toml
[package]
name = "geth"
version = "1.16.7-1"

[docker]
repository = "donbeave/geth"
platforms = ["amd64", "arm64"]
```

### Configuration Fields

- `package.name`: The package name
- `package.version`: The version tag for the Docker image
- `docker.repository`: The Docker repository (e.g., "donbeave/geth")
- `docker.platforms`: List of platforms to build for (e.g., ["amd64", "arm64"])

## Directory Structure

Each package should have the following structure:

```
docker-<package>/
├── build.toml
├── amd64/
│   └── Dockerfile
└── arm64/
    └── Dockerfile
```

For single-platform builds, only include the relevant platform directory.

## Usage

### Build a specific package

Simply provide the package name as an argument:

```bash
rust-script build.rs geth
```

Or navigate to the package directory and run without arguments:

```bash
cd docker-geth
rust-script ../build.rs
```

### Build options

- `PACKAGE`: Package name to build (e.g., "geth", "bitcoin-core")
- `--extra-args <ARGS>` or `-e <ARGS>`: Extra arguments to pass to docker buildx build (default: "--progress plain")
- `--dry-run` or `-n`: Show what would be executed without running
- `--help` or `-h`: Show help message

### Examples

```bash
# Build a package
rust-script build.rs geth

# Build with custom progress output
rust-script build.rs geth --extra-args "--progress auto"

# Dry run to see what would be executed
rust-script build.rs geth --dry-run

# Build with GITHUB_TOKEN (for packages that need it)
GITHUB_TOKEN=your_token rust-script build.rs op-node

# Build from within the package directory
cd docker-geth
rust-script ../build.rs
```

## Build Process

The build script performs the following steps:

1. Reads the `build.toml` configuration file
2. For each platform in `platforms`:
   - Builds the Docker image using `<platform>/Dockerfile`
   - Tags it as `<repository>:<version>-<platform>`
   - Pushes it to the registry
3. If multiple platforms are configured:
   - Creates a multi-platform manifest
   - Pushes the manifest as `<repository>:<version>`

## Migration from build.sh

The old `build.sh` scripts can be replaced with the new system:

### Old way:
```bash
cd docker-geth
./build.sh
```

### New way:
```bash
# From root directory
rust-script build.rs geth

# Or from package directory
cd docker-geth
rust-script ../build.rs
```

## Using with Cargo (Optional)

If you prefer to use `cargo run` instead of `rust-script`:

```bash
cargo run --bin build -- geth
```

## Environment Variables

- `GITHUB_TOKEN`: Automatically passed as a build argument if set (used by some packages)
- `DOCKER_REPOSITORY`: Not used (configured in build.toml instead)

## Notes

- All builds use `--pull` to ensure base images are up to date
- All builds use `--push` to push directly to the registry
- All builds use `--provenance=false` to disable provenance attestation
- Platform prefix `linux/` is automatically added (you only specify `amd64`, `arm64`, etc.)
