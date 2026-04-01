# Unify Dockerfiles With TARGETARCH

## Summary

Refactor the repository from per-architecture Dockerfile pairs such as `Dockerfile.amd64` and `Dockerfile.arm64` to a single `Dockerfile` per `docker-*` package. The standard build path remains `just build` and `./docker-build.rs`, which already invokes `docker buildx build --platform linux/<arch>` and is the only supported build contract for this refactor.

The unified Dockerfiles will use Docker BuildKit's `TARGETARCH` argument to handle architecture-specific behavior such as upstream download artifact names, Debian package names, and arch-specific build commands.

## Goals

- Remove duplicated Dockerfile pairs across the repository.
- Keep the existing build matrix in each package's `build.toml` unchanged.
- Preserve current image behavior for `amd64` and `arm64` builds.
- Keep the implementation local to each Dockerfile where practical.
- Update the build tool and documentation to match the new single-file structure.
- Publish the refactor as a new image revision for every affected container.

## Non-Goals

- Supporting ad-hoc plain `docker build` invocations outside the repo's standard `buildx` flow.
- Introducing shared helper scripts for architecture mapping unless a clear need appears during implementation.
- Changing image tags, manifest generation, or package platform lists.
- Refactoring unrelated Dockerfile logic while doing the unification.

## Current State

The repository currently uses a dual-file pattern in many package directories:

```text
docker-<package>/
├── build.toml
├── Dockerfile.amd64
└── Dockerfile.arm64
```

The build tool in `docker-build.rs` selects `Dockerfile.<platform>` and separately passes `--platform linux/<platform>` to `docker buildx build`.

The current differences between `amd64` and `arm64` Dockerfiles fall into these buckets:

- No real difference other than `FROM --platform=arm64 ...`
- Different upstream artifact names such as `linux-amd64` vs `linux-arm64`
- Different upstream target triples such as `x86_64-unknown-linux-gnu` vs `aarch64-unknown-linux-gnu`
- Different Debian package names such as `linux-headers-amd64` vs `linux-headers-arm64`
- Different build commands such as `make build` vs `make build-arm`
- A few image-specific differences such as alternate package download URLs

## Build Contract

The refactor will rely on the existing repository build path:

- `just build <package>`
- `./docker-build.rs <package>`

`docker-build.rs` will continue to:

- read the package `build.toml`
- iterate the configured `docker.platforms`
- invoke `docker buildx build --platform linux/<arch>`
- build and push one image per platform
- create a multi-platform manifest afterward

The change is that it will always build `Dockerfile` instead of `Dockerfile.<platform>`.

Because the build contract is explicitly tied to `buildx`, the Dockerfiles may assume `TARGETARCH` is available and correct.

## Proposed Structure

Every package directory will use:

```text
docker-<package>/
├── build.toml
└── Dockerfile
```

Single-platform packages will also use `Dockerfile`. Their `build.toml` platform list remains the source of truth for whether they build only `amd64`, only `arm64`, or both.

## Dockerfile Pattern

### Base Form

Unified Dockerfiles will use a single source file with optional architecture branches:

```dockerfile
FROM chainargos/debian-blockchain-base:1.0.0@sha256:...

ARG TARGETARCH
ARG SOME_VERSION

RUN case "$TARGETARCH" in \
      amd64) artifact_arch='amd64' ;; \
      arm64) artifact_arch='arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && curl -L "https://example.com/tool-${artifact_arch}.tar.gz" -o tool.tar.gz
```

### Multi-Stage Builds

For multi-stage builds, `ARG TARGETARCH` will be declared in each stage that needs it. `FROM --platform=arm64` will be removed, because `docker buildx build --platform linux/<arch>` already selects the target architecture.

### Branching Rules

- Keep branches local to the Dockerfile that needs them.
- Prefer a single `case "$TARGETARCH" in ... esac` per logically related step.
- Fail explicitly on unsupported values.
- Do not create shared abstraction layers unless duplication becomes both repeated and identical.

## Architecture Mapping Categories

Implementation will map the existing pair differences into inline `TARGETARCH` branches.

### Download Artifact Names

Examples:

- `linux-amd64` vs `linux-arm64`
- `geth-alltools-linux-amd64-...` vs `geth-alltools-linux-arm64-...`
- `geth_linux` vs `geth-linux-arm64`

### Target Triples

Examples:

- `x86_64-unknown-linux-gnu` vs `aarch64-unknown-linux-gnu`
- `x86_64-linux-gnu` vs `aarch64-linux-gnu`

### Debian Package Names

Examples:

- `linux-headers-amd64` vs `linux-headers-arm64`

### Build Commands

Examples:

- `make build` vs `make build-arm`
- `make geth` vs `make geth-musl`

### Image-Specific URLs

Some upstream projects expose architecture-specific URLs that do not differ by a simple suffix. Those Dockerfiles will use a direct `case` mapping to preserve the exact current URLs.

## File-Level Changes

### Versioning

Because this refactor changes how every affected image is built and packaged, the implementation will also increase the container release revision for every affected package.

- Keep the upstream software `version` field unchanged.
- Increment the package `build` field in each affected `docker-*/build.toml` so the refactored images publish as a new container revision.
- Apply the version bump consistently across all affected packages in the same rollout.

### Build Tool

Update `docker-build.rs` to:

- use `Dockerfile` instead of `Dockerfile.<platform>`
- keep the platform loop unchanged
- keep CLI option ordering stable where order does not affect behavior

No change is required to `build.toml` platform lists.

### Package Directories

For every package:

- create or retain a single `Dockerfile`
- merge `Dockerfile.amd64` and `Dockerfile.arm64` logic into it
- remove the old pair files

### Documentation

Update at minimum:

- `BUILD_SYSTEM.md`
- `README.md`

Remove references to paired Dockerfiles and document the new single-file structure.

## Error Handling

Unified Dockerfiles will fail fast when `TARGETARCH` is not one of the supported values for that package:

```sh
case "$TARGETARCH" in
  amd64) ... ;;
  arm64) ... ;;
  *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;;
esac
```

This keeps failures readable and prevents silent misuse.

## Testing And Verification

Verification will focus on the repository's supported build path.

### Static Verification

- confirm the repo no longer relies on `Dockerfile.amd64` or `Dockerfile.arm64`
- confirm docs describe `Dockerfile` instead of paired files
- confirm the build tool points at `Dockerfile`

### Dry-Run Verification

Run `./docker-build.rs <package> --dry-run` for representative packages, including:

- a simple package where the only difference was the inline platform pin
- a package with architecture-specific download names
- a package with architecture-specific Debian packages
- a package with architecture-specific build commands

The generated commands should still include:

- `docker buildx build`
- `--platform linux/amd64`
- `--platform linux/arm64`
- `-f Dockerfile`

### Risk Areas

The main behavioral risk is incorrect architecture mapping inside a unified Dockerfile. The most likely failures are:

- wrong artifact file names
- wrong Debian package names
- wrong build target selection
- missing `ARG TARGETARCH` in a stage that needs it

Representative dry runs and careful pair-by-pair merging are the primary mitigations.

## Rollout Plan

1. Update `docker-build.rs` to use `Dockerfile`.
2. Unify paired package Dockerfiles into one file each.
3. Normalize single-platform package directories to `Dockerfile` where appropriate.
4. Delete obsolete `Dockerfile.amd64` and `Dockerfile.arm64` files.
5. Increment the `build` value in each affected `docker-*/build.toml`.
6. Update repository documentation.
7. Run dry-run verification on representative packages.

## Open Decisions Resolved

- Use inline `TARGETARCH` branching rather than helper scripts.
- Support only the repository's standard `buildx` flow.
- Apply the refactor across the full repository, not as a pilot.

## Recommendation

Proceed with the inline `TARGETARCH` refactor. It removes a large amount of duplicated Dockerfile content while preserving the existing build pipeline and keeping architecture-specific behavior explicit at the point where it matters.
