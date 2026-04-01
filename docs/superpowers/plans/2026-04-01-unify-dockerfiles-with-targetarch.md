# Unify Dockerfiles With TARGETARCH Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace every per-architecture Dockerfile pair with a single `Dockerfile`, route architecture differences through `TARGETARCH`, and publish the refactor as a new image revision across the full container set.

**Architecture:** Migrate in two phases. First, make the build tool accept `Dockerfile` while the repo is mixed, then convert Dockerfiles in category batches. After all Dockerfiles are unified, publish new `debian-blockchain-base` and `debian-blockchain-build` revisions, capture their new digests, update every downstream `FROM` pin, bump package `build` numbers, and remove the temporary fallback from the build tool.

**Tech Stack:** Docker Buildx, Dockerfile/BuildKit `TARGETARCH`, Rust `rust-script`, Python 3 for mechanical file rewrites, ripgrep for verification.

---

## File Structure

**Build orchestration**
- Modify: `docker-build.rs`
- Responsibility: Select the right Dockerfile path, pass platform/build args, and print dry-run output.

**Documentation**
- Modify: `BUILD_SYSTEM.md`
- Modify: `README.md`
- Responsibility: Describe the new single-file Dockerfile structure and versioning examples.

**Base images**
- Modify: `docker-debian-blockchain-base/Dockerfile.amd64`
- Modify: `docker-debian-blockchain-base/Dockerfile.arm64`
- Create: `docker-debian-blockchain-base/Dockerfile`
- Modify: `docker-debian-blockchain-base/build.toml`
- Modify: `docker-debian-blockchain-build/Dockerfile.amd64`
- Modify: `docker-debian-blockchain-build/Dockerfile.arm64`
- Create: `docker-debian-blockchain-build/Dockerfile`
- Modify: `docker-debian-blockchain-build/build.toml`
- Responsibility: Provide the pinned base and build images that most other Dockerfiles inherit from.

**Rename-only multi-arch packages**
- Modify: `docker-arbitrum/Dockerfile.amd64`
- Modify: `docker-arbitrum/Dockerfile.arm64`
- Modify: `docker-bor/Dockerfile.amd64`
- Modify: `docker-bor/Dockerfile.arm64`
- Modify: `docker-celo-op-geth/Dockerfile.amd64`
- Modify: `docker-celo-op-geth/Dockerfile.arm64`
- Modify: `docker-celo-op-node/Dockerfile.amd64`
- Modify: `docker-celo-op-node/Dockerfile.arm64`
- Modify: `docker-eigenda-proxy/Dockerfile.amd64`
- Modify: `docker-eigenda-proxy/Dockerfile.arm64`
- Modify: `docker-fetchd/Dockerfile.amd64`
- Modify: `docker-fetchd/Dockerfile.arm64`
- Modify: `docker-fraxtal-op-geth/Dockerfile.amd64`
- Modify: `docker-fraxtal-op-geth/Dockerfile.arm64`
- Modify: `docker-fraxtal-op-node/Dockerfile.amd64`
- Modify: `docker-fraxtal-op-node/Dockerfile.arm64`
- Modify: `docker-gnosis-geth/Dockerfile.amd64`
- Modify: `docker-gnosis-geth/Dockerfile.arm64`
- Modify: `docker-op-geth/Dockerfile.amd64`
- Modify: `docker-op-geth/Dockerfile.arm64`
- Modify: `docker-op-node/Dockerfile.amd64`
- Modify: `docker-op-node/Dockerfile.arm64`
- Modify: `docker-ronin-geth/Dockerfile.amd64`
- Modify: `docker-ronin-geth/Dockerfile.arm64`
- Modify: `docker-scroll-geth/Dockerfile.amd64`
- Modify: `docker-scroll-geth/Dockerfile.arm64`
- Modify: `docker-sonic-geth/Dockerfile.amd64`
- Modify: `docker-sonic-geth/Dockerfile.arm64`
- Modify: `docker-wbt-geth/Dockerfile.amd64`
- Modify: `docker-wbt-geth/Dockerfile.arm64`
- Responsibility: These pairs differ only by `FROM --platform=arm64`, so the amd64 file can become the shared `Dockerfile`.

**Single-platform rename-only packages**
- Modify: `docker-beacon-kit/Dockerfile.amd64`
- Modify: `docker-bnb-beacon-chain/Dockerfile.amd64`
- Modify: `docker-heco-geth/Dockerfile.amd64`
- Modify: `docker-kcc-geth/Dockerfile.amd64`
- Modify: `docker-tron-java/Dockerfile.amd64`
- Responsibility: Rename the lone architecture-specific Dockerfile to `Dockerfile` without adding `TARGETARCH` logic.

**Arch-mapped download packages**
- Modify: `docker-avalanchego/Dockerfile.amd64`
- Modify: `docker-avalanchego/Dockerfile.arm64`
- Modify: `docker-bera-reth/Dockerfile.amd64`
- Modify: `docker-bera-reth/Dockerfile.arm64`
- Modify: `docker-bitcoin-cash/Dockerfile.amd64`
- Modify: `docker-bitcoin-cash/Dockerfile.arm64`
- Modify: `docker-bitcoin-core/Dockerfile.amd64`
- Modify: `docker-bitcoin-core/Dockerfile.arm64`
- Modify: `docker-bsc-geth/Dockerfile.amd64`
- Modify: `docker-bsc-geth/Dockerfile.arm64`
- Modify: `docker-cardano-node/Dockerfile.amd64`
- Modify: `docker-cardano-node/Dockerfile.arm64`
- Modify: `docker-dogecoin-core/Dockerfile.amd64`
- Modify: `docker-dogecoin-core/Dockerfile.arm64`
- Modify: `docker-geth/Dockerfile.amd64`
- Modify: `docker-geth/Dockerfile.arm64`
- Modify: `docker-lighthouse/Dockerfile.amd64`
- Modify: `docker-lighthouse/Dockerfile.arm64`
- Modify: `docker-litecoin-core/Dockerfile.amd64`
- Modify: `docker-litecoin-core/Dockerfile.arm64`
- Modify: `docker-octez/Dockerfile.amd64`
- Modify: `docker-octez/Dockerfile.arm64`
- Modify: `docker-omnicore/Dockerfile.amd64`
- Modify: `docker-omnicore/Dockerfile.arm64`
- Responsibility: Use `TARGETARCH` to map upstream archive names, target triples, or fixed file IDs.

**Arch-mapped build-command packages**
- Modify: `docker-celo-geth/Dockerfile.amd64`
- Modify: `docker-celo-geth/Dockerfile.arm64`
- Modify: `docker-heimdall/Dockerfile.amd64`
- Modify: `docker-heimdall/Dockerfile.arm64`
- Responsibility: Use `TARGETARCH` to choose the right make target.

**Version metadata**
- Modify: every `docker-*/build.toml`
- Responsibility: Publish the refactor as a new container revision. Existing `build = "1"` values become `build = "2"`; `docker-debian-blockchain-base/build.toml` and `docker-debian-blockchain-build/build.toml` gain `build = "1"`.

### Task 1: Add Temporary `Dockerfile` Fallback

**Files:**
- Modify: `docker-build.rs`

- [ ] **Step 1: Capture the current dry-run output before any migration changes**

Run:

```bash
./docker-build.rs op-node --dry-run
./docker-build.rs beacon-kit --dry-run
```

Expected:
- The `op-node` dry run prints `Dockerfile: Dockerfile.amd64` and `Dockerfile: Dockerfile.arm64`.
- The `beacon-kit` dry run prints `Dockerfile: Dockerfile.amd64`.

- [ ] **Step 2: Teach `docker-build.rs` to prefer `Dockerfile` and fall back to `Dockerfile.<platform>` during the migration**

Replace the Dockerfile path selection in `docker-build.rs` with this helper and call site:

```rust
fn resolve_dockerfile_path(build_dir: &Path, platform: &str) -> Result<String> {
    let plain = build_dir.join("Dockerfile");
    if plain.exists() {
        return Ok(String::from("Dockerfile"));
    }

    let legacy_name = format!("Dockerfile.{platform}");
    let legacy = build_dir.join(&legacy_name);
    if legacy.exists() {
        return Ok(legacy_name);
    }

    anyhow::bail!(
        "No Dockerfile found in {} (checked Dockerfile and Dockerfile.{platform})",
        build_dir.display()
    );
}

fn build_platform(
    build_dir: &Path,
    config: &BuildConfig,
    platform: &str,
    extra_args: &str,
    github_token: Option<&str>,
    dry_run: bool,
) -> Result<()> {
    let platform_tag = format!(
        "{}:{}-{}",
        config.docker.repository,
        config.package.full_version(),
        platform
    );

    let dockerfile_path = resolve_dockerfile_path(build_dir, platform)?;
```

- [ ] **Step 3: Re-run the same dry runs and confirm legacy packages still resolve exactly as before**

Run:

```bash
./docker-build.rs op-node --dry-run
./docker-build.rs beacon-kit --dry-run
```

Expected:
- Output is unchanged from Step 1 because no `Dockerfile` files exist yet.
- No errors about missing Dockerfiles.

- [ ] **Step 4: Commit the migration-safe build-tool change**

```bash
git add docker-build.rs
git commit -m "Add temporary unified Dockerfile fallback"
```

### Task 2: Unify The Base Images First

**Files:**
- Create: `docker-debian-blockchain-base/Dockerfile`
- Delete: `docker-debian-blockchain-base/Dockerfile.amd64`
- Delete: `docker-debian-blockchain-base/Dockerfile.arm64`
- Create: `docker-debian-blockchain-build/Dockerfile`
- Delete: `docker-debian-blockchain-build/Dockerfile.amd64`
- Delete: `docker-debian-blockchain-build/Dockerfile.arm64`

- [ ] **Step 1: Replace `docker-debian-blockchain-base` with a single `TARGETARCH`-aware Dockerfile**

Run:

```bash
cat > docker-debian-blockchain-base/Dockerfile <<'EOF'
FROM debian:trixie-20260316@sha256:55a15a112b42be10bfc8092fcc40b6748dc236f7ef46a358d9392b339e9d60e8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV XH_VERSION=0.25.0
ENV GOMPLATE_VERSION=4.3.3

ARG TARGETARCH

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
               ca-certificates \
               curl \
               wget \
               git \
               unzip \
               xz-utils \
               procps \
               jq \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/* \
              /var/cache/apt/* \
              /tmp/*

RUN case "$TARGETARCH" in \
      amd64) xh_arch='x86_64-unknown-linux-musl' ;; \
      arm64) xh_arch='aarch64-unknown-linux-musl' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/ducaale/xh/releases/download/v${XH_VERSION}/xh-v${XH_VERSION}-${xh_arch}.tar.gz -o xh.tar.gz \
    && tar -xvf xh.tar.gz \
    && rm xh.tar.gz \
    && mv xh-*/xh /usr/local/bin/xh \
    && chmod a+x /usr/local/bin/xh \
    && rm -r xh-* \
    && rm -rf /tmp/*

RUN case "$TARGETARCH" in \
      amd64) gomplate_arch='amd64' ;; \
      arm64) gomplate_arch='arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-${gomplate_arch} -o gomplate \
    && mv gomplate /usr/local/bin/gomplate \
    && chmod a+x /usr/local/bin/gomplate \
    && rm -rf /tmp/*

RUN set -ex \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://mise.jdx.dev/gpg-key.pub -o /etc/apt/keyrings/mise.asc \
    && chmod a+r /etc/apt/keyrings/mise.asc

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/mise.asc] https://mise.jdx.dev/deb stable main" > /etc/apt/sources.list.d/mise.list

RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
               mise \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/* \
              /var/cache/apt/* \
              /tmp/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV MISE_CONFIG_DIR=/opt/mise/config
ENV MISE_STATE_DIR=/opt/mise/state
ENV MISE_DATA_DIR=/opt/mise/data
ENV MISE_INSTALL_PATH=/usr/bin/mise

ENV PATH="/opt/mise/data/shims:$PATH"
EOF

rm docker-debian-blockchain-base/Dockerfile.amd64 docker-debian-blockchain-base/Dockerfile.arm64
```

- [ ] **Step 2: Replace `docker-debian-blockchain-build` with a single `TARGETARCH`-aware Dockerfile**

Run:

```bash
cat > docker-debian-blockchain-build/Dockerfile <<'EOF'
FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8 AS build

ARG TARGETARCH

RUN case "$TARGETARCH" in \
      amd64) linux_headers_pkg='linux-headers-amd64'; extra_packages='' ;; \
      arm64) linux_headers_pkg='linux-headers-arm64'; extra_packages='musl-dev' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
               build-essential \
               ${extra_packages} \
               git \
               ${linux_headers_pkg} \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/* \
              /var/cache/apt/* \
              /tmp/*

RUN mise install go@1.22.12
RUN mise install go@1.25.3

RUN mise use -g --pin go@1.25.3
EOF

rm docker-debian-blockchain-build/Dockerfile.amd64 docker-debian-blockchain-build/Dockerfile.arm64
```

- [ ] **Step 3: Dry-run both base image builds and confirm the new plain Dockerfile is selected**

Run:

```bash
./docker-build.rs debian-blockchain-base --dry-run
./docker-build.rs debian-blockchain-build --dry-run
```

Expected:
- Each dry run prints `Dockerfile: Dockerfile`.
- Each command still prints `--platform linux/amd64` and `--platform linux/arm64`.

- [ ] **Step 4: Commit the base-image unification**

```bash
git add docker-debian-blockchain-base/Dockerfile docker-debian-blockchain-build/Dockerfile
git add -u docker-debian-blockchain-base docker-debian-blockchain-build
git commit -m "Unify blockchain base image Dockerfiles"
```

### Task 3: Convert Rename-Only Packages

**Files:**
- Create and delete under the rename-only package lists in the File Structure section.

- [ ] **Step 1: Convert the multi-arch rename-only packages by copying the amd64 file to `Dockerfile` and removing the pair**

Run:

```bash
python3 - <<'PY'
from pathlib import Path

root = Path('/Users/donbeave/Projects/ChainArgos/blockchain-nodes')
dirs = [
    'docker-arbitrum',
    'docker-bor',
    'docker-celo-op-geth',
    'docker-celo-op-node',
    'docker-eigenda-proxy',
    'docker-fetchd',
    'docker-fraxtal-op-geth',
    'docker-fraxtal-op-node',
    'docker-gnosis-geth',
    'docker-op-geth',
    'docker-op-node',
    'docker-ronin-geth',
    'docker-scroll-geth',
    'docker-sonic-geth',
    'docker-wbt-geth',
]

for name in dirs:
    d = root / name
    (d / 'Dockerfile').write_text((d / 'Dockerfile.amd64').read_text())
    (d / 'Dockerfile.amd64').unlink()
    (d / 'Dockerfile.arm64').unlink()
PY
```

- [ ] **Step 2: Rename the single-platform amd64 Dockerfiles to `Dockerfile`**

Run:

```bash
for dir in \
  docker-beacon-kit \
  docker-bnb-beacon-chain \
  docker-heco-geth \
  docker-kcc-geth \
  docker-tron-java
do
  mv "$dir/Dockerfile.amd64" "$dir/Dockerfile"
done
```

- [ ] **Step 3: Verify the converted packages no longer contain legacy platform-pinned `FROM` lines**

Run:

```bash
rg -n '^FROM --platform=arm64 ' \
  docker-arbitrum/Dockerfile \
  docker-bor/Dockerfile \
  docker-celo-op-geth/Dockerfile \
  docker-celo-op-node/Dockerfile \
  docker-eigenda-proxy/Dockerfile \
  docker-fetchd/Dockerfile \
  docker-fraxtal-op-geth/Dockerfile \
  docker-fraxtal-op-node/Dockerfile \
  docker-gnosis-geth/Dockerfile \
  docker-op-geth/Dockerfile \
  docker-op-node/Dockerfile \
  docker-ronin-geth/Dockerfile \
  docker-scroll-geth/Dockerfile \
  docker-sonic-geth/Dockerfile \
  docker-wbt-geth/Dockerfile
```

Expected:
- No output.

- [ ] **Step 4: Dry-run a multi-arch package and a single-platform package to confirm the new file path is active**

Run:

```bash
./docker-build.rs op-node --dry-run
./docker-build.rs beacon-kit --dry-run
```

Expected:
- Both runs print `Dockerfile: Dockerfile`.
- `op-node` still emits both `--platform linux/amd64` and `--platform linux/arm64`.

- [ ] **Step 5: Commit the rename-only conversion batch**

```bash
git add docker-arbitrum docker-bor docker-celo-op-geth docker-celo-op-node docker-eigenda-proxy
git add docker-fetchd docker-fraxtal-op-geth docker-fraxtal-op-node docker-gnosis-geth
git add docker-op-geth docker-op-node docker-ronin-geth docker-scroll-geth docker-sonic-geth docker-wbt-geth
git add docker-beacon-kit docker-bnb-beacon-chain docker-heco-geth docker-kcc-geth docker-tron-java
git commit -m "Collapse rename-only Dockerfile pairs"
```

### Task 4: Convert Arch-Mapped Download Packages

**Files:**
- Create and delete under the arch-mapped download package list in the File Structure section.

- [ ] **Step 1: Rewrite the simple `amd64`/`arm64` archive-name packages**

Run:

```bash
python3 - <<'PY'
from pathlib import Path

root = Path('/Users/donbeave/Projects/ChainArgos/blockchain-nodes')

replacements = {
    'docker-avalanchego': (
        'ARG AVALANCHEGO_VERSION\n\nRUN cd /tmp \\\n+    && curl -L https://github.com/ava-labs/avalanchego/releases/download/v${AVALANCHEGO_VERSION}/avalanchego-linux-amd64-v${AVALANCHEGO_VERSION}.tar.gz -o avalanchego.tar.gz \\\n+',
        'ARG TARGETARCH\nARG AVALANCHEGO_VERSION\n\nRUN case "$TARGETARCH" in \\\n+      amd64) artifact_arch="amd64" ;; \\\n+      arm64) artifact_arch="arm64" ;; \\\n+      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \\\n+    esac \\\n+    && cd /tmp \\\n+    && curl -L https://github.com/ava-labs/avalanchego/releases/download/v${AVALANCHEGO_VERSION}/avalanchego-linux-${artifact_arch}-v${AVALANCHEGO_VERSION}.tar.gz -o avalanchego.tar.gz \\\n+'
    ),
    'docker-cardano-node': (
        'ARG CARDANO_NODE_VERSION\n\nRUN cd /tmp \\\n+    && curl -L https://github.com/IntersectMBO/cardano-node/releases/download/${CARDANO_NODE_VERSION}/cardano-node-${CARDANO_NODE_VERSION}-linux-amd64.tar.gz -o cardano-node.tar.gz \\\n+',
        'ARG TARGETARCH\nARG CARDANO_NODE_VERSION\n\nRUN case "$TARGETARCH" in \\\n+      amd64) artifact_arch="amd64" ;; \\\n+      arm64) artifact_arch="arm64" ;; \\\n+      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \\\n+    esac \\\n+    && cd /tmp \\\n+    && curl -L https://github.com/IntersectMBO/cardano-node/releases/download/${CARDANO_NODE_VERSION}/cardano-node-${CARDANO_NODE_VERSION}-linux-${artifact_arch}.tar.gz -o cardano-node.tar.gz \\\n+'
    ),
    'docker-geth': (
        'ARG GETH_VERSION\nARG GIT_COMMIT\nARG LEGACY_VERSION\nARG LEGACY_GIT_COMMIT\n\nRUN cd /tmp \\\n+    && curl -L https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-${GETH_VERSION}-${GIT_COMMIT}.tar.gz -o geth.tar.gz \\\n+',
        'ARG TARGETARCH\nARG GETH_VERSION\nARG GIT_COMMIT\nARG LEGACY_VERSION\nARG LEGACY_GIT_COMMIT\n\nRUN case "$TARGETARCH" in \\\n+      amd64) artifact_arch="amd64" ;; \\\n+      arm64) artifact_arch="arm64" ;; \\\n+      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \\\n+    esac \\\n+    && cd /tmp \\\n+    && curl -L https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-${artifact_arch}-${GETH_VERSION}-${GIT_COMMIT}.tar.gz -o geth.tar.gz \\\n+'
    ),
}

for name, (old, new) in replacements.items():
    d = root / name
    text = (d / 'Dockerfile.amd64').read_text()
    text = text.replace(old, new)
    if name == 'docker-geth':
        text = text.replace(
            'RUN cd /tmp \\\n+    && curl -L https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-${LEGACY_VERSION}-${LEGACY_GIT_COMMIT}.tar.gz -o geth.tar.gz \\\n+',
            'RUN case "$TARGETARCH" in \\\n+      amd64) artifact_arch="amd64" ;; \\\n+      arm64) artifact_arch="arm64" ;; \\\n+      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \\\n+    esac \\\n+    && cd /tmp \\\n+    && curl -L https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-${artifact_arch}-${LEGACY_VERSION}-${LEGACY_GIT_COMMIT}.tar.gz -o geth.tar.gz \\\n+'
        )
    (d / 'Dockerfile').write_text(text)
    (d / 'Dockerfile.amd64').unlink()
    (d / 'Dockerfile.arm64').unlink()
PY
```

- [ ] **Step 2: Rewrite the target-triple archive packages**

Run:

```bash
python3 - <<'PY'
from pathlib import Path

root = Path('/Users/donbeave/Projects/ChainArgos/blockchain-nodes')

targets = {
    'docker-bera-reth': ('x86_64-unknown-linux-gnu', 'aarch64-unknown-linux-gnu'),
    'docker-bitcoin-cash': ('x86_64-linux-gnu', 'aarch64-linux-gnu'),
    'docker-bitcoin-core': ('x86_64-linux-gnu', 'aarch64-linux-gnu'),
    'docker-dogecoin-core': ('x86_64-linux-gnu', 'aarch64-linux-gnu'),
    'docker-lighthouse': ('x86_64-unknown-linux-gnu', 'aarch64-unknown-linux-gnu'),
    'docker-litecoin-core': ('x86_64-linux-gnu', 'aarch64-linux-gnu'),
    'docker-omnicore': ('x86_64-linux-gnu', 'aarch64-linux-gnu'),
}

for name, (amd64_token, arm64_token) in targets.items():
    d = root / name
    text = (d / 'Dockerfile.amd64').read_text()
    text = text.replace('LABEL org.opencontainers.image.authors="alexey@zhokhov.com"\n\n', 'LABEL org.opencontainers.image.authors="alexey@zhokhov.com"\n\nARG TARGETARCH\n\n')
    text = text.replace(
        amd64_token,
        '${artifact_arch}'
    )
    text = text.replace(
        'RUN cd /tmp \\\n+    && curl -L ',
        'RUN case "$TARGETARCH" in \\\n+      amd64) artifact_arch="' + amd64_token + '" ;; \\\n+      arm64) artifact_arch="' + arm64_token + '" ;; \\\n+      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \\\n+    esac \\\n+    && cd /tmp \\\n+    && curl -L '
    )
    (d / 'Dockerfile').write_text(text)
    (d / 'Dockerfile.amd64').unlink()
    (d / 'Dockerfile.arm64').unlink()
PY
```

- [ ] **Step 3: Rewrite the custom URL packages explicitly**

Run:

```bash
cat > docker-bsc-geth/Dockerfile <<'EOF'
FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH
ARG BSC_GETH_VERSION

RUN case "$TARGETARCH" in \
      amd64) artifact_name='geth_linux' ;; \
      arm64) artifact_name='geth-linux-arm64' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && curl -L https://github.com/bnb-chain/bsc/releases/download/v${BSC_GETH_VERSION}/${artifact_name} -o /usr/local/bin/geth \
    && chmod -v u+x /usr/local/bin/geth \
    && /usr/local/bin/geth --version

ADD config/config.toml /config/
ADD config/genesis.json /config/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
EOF

cat > docker-octez/Dockerfile <<'EOF'
FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

ARG TARGETARCH

RUN case "$TARGETARCH" in \
      amd64) package_file_id='166077302' ;; \
      arm64) package_file_id='166078371' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && cd /tmp \
    && curl -L https://gitlab.com/tezos/tezos/-/package_files/${package_file_id}/download -o octez.tar.gz \
    && tar -xvf octez.tar.gz \
    && rm octez.tar.gz \
    && mv octez-*/octez-node /usr/local/bin/ \
    && rm -rf octez-* \
    && chmod -v u+x /usr/local/bin/* \
    && rm -rf /tmp/*

RUN cd /tmp \
    && curl -L https://raw.githubusercontent.com/zcash/zcash/713fc761dd9cf4c9087c37b078bdeab98697bad2/zcutil/fetch-params.sh -o fetch-params.sh \
    && chmod +x fetch-params.sh \
    && ./fetch-params.sh \
    && rm fetch-params.sh \
    && rm -rf /tmp/*

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
EOF

rm docker-bsc-geth/Dockerfile.amd64 docker-bsc-geth/Dockerfile.arm64
rm docker-octez/Dockerfile.amd64 docker-octez/Dockerfile.arm64
```

- [ ] **Step 4: Dry-run representative download-mapped packages**

Run:

```bash
./docker-build.rs geth --dry-run
./docker-build.rs octez --dry-run
./docker-build.rs bsc-geth --dry-run
```

Expected:
- Every run prints `Dockerfile: Dockerfile`.
- `geth` and `octez` still emit both target platforms.

- [ ] **Step 5: Commit the download-mapping conversion batch**

```bash
git add docker-avalanchego docker-bera-reth docker-bitcoin-cash docker-bitcoin-core docker-bsc-geth
git add docker-cardano-node docker-dogecoin-core docker-geth docker-lighthouse docker-litecoin-core
git add docker-octez docker-omnicore
git commit -m "Unify download-based Dockerfile pairs"
```

### Task 5: Convert Build-Command Packages And Finish The Tooling Cleanup

**Files:**
- Create: `docker-celo-geth/Dockerfile`
- Delete: `docker-celo-geth/Dockerfile.amd64`
- Delete: `docker-celo-geth/Dockerfile.arm64`
- Create: `docker-heimdall/Dockerfile`
- Delete: `docker-heimdall/Dockerfile.amd64`
- Delete: `docker-heimdall/Dockerfile.arm64`
- Modify: `docker-build.rs`
- Modify: `BUILD_SYSTEM.md`
- Modify: `README.md`

- [ ] **Step 1: Rewrite `docker-celo-geth` and `docker-heimdall` to select their make target from `TARGETARCH`**

Run:

```bash
cat > docker-celo-geth/Dockerfile <<'EOF'
FROM chainargos/debian-blockchain-build:1.0.0@sha256:b4989a6d9564295dcf4ffd085fbcb717c176864b38054489bdb2b642a1e2b3a7 AS build

ARG TARGETARCH

RUN mise use -g --pin go@1.22.12

ARG CELO_GETH_VERSION

RUN git clone --branch v${CELO_GETH_VERSION} --single-branch --depth=1 https://github.com/celo-org/celo-blockchain.git

WORKDIR /celo-blockchain

RUN case "$TARGETARCH" in \
      amd64) make_target='geth' ;; \
      arm64) make_target='geth-musl' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && make ${make_target}
# end build

FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

COPY --from=build /celo-blockchain/build/bin/geth /usr/local/bin/

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
EOF

cat > docker-heimdall/Dockerfile <<'EOF'
FROM chainargos/debian-blockchain-build:1.0.0@sha256:b4989a6d9564295dcf4ffd085fbcb717c176864b38054489bdb2b642a1e2b3a7 AS build

ARG TARGETARCH
ARG HEIMDALL_VERSION

RUN git clone --branch v${HEIMDALL_VERSION} --single-branch --depth=1 https://github.com/0xPolygon/heimdall-v2.git

WORKDIR /heimdall-v2

RUN case "$TARGETARCH" in \
      amd64) make_target='build' ;; \
      arm64) make_target='build-arm' ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac \
    && make ${make_target}
# end build

FROM chainargos/debian-blockchain-base:1.0.0@sha256:060d1ab619195aa9003050a65124d38ae3f2f1ea1af5b62a983adc0713fd69a8

LABEL org.opencontainers.image.authors="alexey@zhokhov.com"

COPY --from=build /heimdall-v2/build/heimdalld /usr/local/bin/

ADD config /config/

COPY start.sh /
RUN chmod a+x /start.sh

RUN mkdir -pv /data
VOLUME /data
WORKDIR /data

COPY docker-entrypoint.sh /
RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/start.sh"]
EOF

rm docker-celo-geth/Dockerfile.amd64 docker-celo-geth/Dockerfile.arm64
rm docker-heimdall/Dockerfile.amd64 docker-heimdall/Dockerfile.arm64
```

- [ ] **Step 2: Remove the temporary fallback and require `Dockerfile` everywhere**

Change the helper in `docker-build.rs` to this final form:

```rust
fn resolve_dockerfile_path(build_dir: &Path) -> Result<String> {
    let plain = build_dir.join("Dockerfile");
    if plain.exists() {
        return Ok(String::from("Dockerfile"));
    }

    anyhow::bail!(
        "No Dockerfile found in {} (expected Dockerfile)",
        build_dir.display()
    );
}

fn build_platform(
    build_dir: &Path,
    config: &BuildConfig,
    platform: &str,
    extra_args: &str,
    github_token: Option<&str>,
    dry_run: bool,
) -> Result<()> {
    let platform_tag = format!(
        "{}:{}-{}",
        config.docker.repository,
        config.package.full_version(),
        platform
    );

    let dockerfile_path = resolve_dockerfile_path(build_dir)?;
```

- [ ] **Step 3: Update the docs to describe the single-file structure and the packaging-version behavior**

Apply these exact text replacements:

```text
BUILD_SYSTEM.md
- Replace the directory structure example with:
  docker-<package>/
  ├── build.toml
  └── Dockerfile
- Replace "For single-platform builds, only include the relevant Dockerfile (e.g., only `Dockerfile.amd64`)."
  with "For single-platform builds, keep a single `Dockerfile`; the `platforms` list in `build.toml` controls which architectures are built."
- Replace the example "version = \"1.0.0\" (no build field) → Docker tag: `chainargos/debian-blockchain-base:1.0.0`"
  with "version = \"1.0.0\" + build = \"1\" → Docker tag: `chainargos/debian-blockchain-base:1.0.0-1`"

README.md
- Replace the project-structure block entries
  `Dockerfile.amd64 # AMD64 Dockerfile`
  `Dockerfile.arm64 # ARM64 Dockerfile`
  with
  `Dockerfile       # Dockerfile used for every configured platform`
```

- [ ] **Step 4: Verify the repo no longer references the legacy Dockerfile names in code or docs**

Run:

```bash
./docker-build.rs celo-geth --dry-run
./docker-build.rs heimdall --dry-run
rg -n 'Dockerfile\.(amd64|arm64)' README.md BUILD_SYSTEM.md docker-build.rs
```

Expected:
- The dry runs print `Dockerfile: Dockerfile`.
- The final `rg` command produces no output.

- [ ] **Step 5: Commit the build-command conversion and final Dockerfile-tooling cleanup**

```bash
git add docker-celo-geth docker-heimdall docker-build.rs BUILD_SYSTEM.md README.md
git commit -m "Finish unified Dockerfile migration"
```

### Task 6: Bump Build Revisions And Refresh Base/Build Digests

**Files:**
- Modify: every `docker-*/build.toml`
- Modify: every `docker-*/Dockerfile` that references `chainargos/debian-blockchain-base` or `chainargos/debian-blockchain-build`

- [ ] **Step 1: Add or increment the `build` field in every package config**

Run:

```bash
python3 - <<'PY'
from pathlib import Path

root = Path('/Users/donbeave/Projects/ChainArgos/blockchain-nodes')
for path in sorted(root.glob('docker-*/build.toml')):
    text = path.read_text()
    if 'build = "1"' in text:
        path.write_text(text.replace('build = "1"', 'build = "2"', 1))
        continue
    if path.parent.name in {'docker-debian-blockchain-base', 'docker-debian-blockchain-build'}:
        path.write_text(text.replace('version = "1.0.0"\n', 'version = "1.0.0"\nbuild = "1"\n', 1))
PY
```

Expected:
- `docker-debian-blockchain-base/build.toml` and `docker-debian-blockchain-build/build.toml` now contain `build = "1"`.
- Every other `build.toml` changes from `build = "1"` to `build = "2"`.

- [ ] **Step 2: Publish the new base image revision and capture its manifest digest**

Run:

```bash
./docker-build.rs debian-blockchain-base
BASE_DIGEST="$(docker buildx imagetools inspect chainargos/debian-blockchain-base:1.0.0-1 | sed -n 's/^Digest: //p')"
export BASE_DIGEST
printf '%s\n' "$BASE_DIGEST"
```

Expected:
- `./docker-build.rs debian-blockchain-base` finishes successfully.
- `printf` prints a single `sha256:...` digest.

- [ ] **Step 3: Update every `debian-blockchain-base` pin to the new `1.0.0-1` tag and digest**

Run:

```bash
BASE_DIGEST="$(docker buildx imagetools inspect chainargos/debian-blockchain-base:1.0.0-1 | sed -n 's/^Digest: //p')"
export BASE_DIGEST
python3 - <<'PY'
from pathlib import Path
import os
import re

root = Path('/Users/donbeave/Projects/ChainArgos/blockchain-nodes')
pattern = re.compile(r'chainargos/debian-blockchain-base:1\.0\.0@sha256:[0-9a-f]{64}')
replacement = f'chainargos/debian-blockchain-base:1.0.0-1@{os.environ["BASE_DIGEST"]}'

for path in sorted(root.glob('docker-*/Dockerfile')):
    text = path.read_text()
    new_text = pattern.sub(replacement, text)
    if new_text != text:
        path.write_text(new_text)
PY
```

Expected:
- `rg -n 'chainargos/debian-blockchain-base:1\.0\.0@' docker-*/Dockerfile` returns no matches.
- `rg -n 'chainargos/debian-blockchain-base:1\.0\.0-1@' docker-*/Dockerfile` returns the expected set of Dockerfiles.

- [ ] **Step 4: Publish the new build image revision and capture its manifest digest**

Run:

```bash
./docker-build.rs debian-blockchain-build
BUILD_DIGEST="$(docker buildx imagetools inspect chainargos/debian-blockchain-build:1.0.0-1 | sed -n 's/^Digest: //p')"
export BUILD_DIGEST
printf '%s\n' "$BUILD_DIGEST"
```

Expected:
- `./docker-build.rs debian-blockchain-build` finishes successfully.
- `printf` prints a single `sha256:...` digest.

- [ ] **Step 5: Update every `debian-blockchain-build` pin to the new `1.0.0-1` tag and digest**

Run:

```bash
BUILD_DIGEST="$(docker buildx imagetools inspect chainargos/debian-blockchain-build:1.0.0-1 | sed -n 's/^Digest: //p')"
export BUILD_DIGEST
python3 - <<'PY'
from pathlib import Path
import os
import re

root = Path('/Users/donbeave/Projects/ChainArgos/blockchain-nodes')
pattern = re.compile(r'chainargos/debian-blockchain-build:1\.0\.0@sha256:[0-9a-f]{64}')
replacement = f'chainargos/debian-blockchain-build:1.0.0-1@{os.environ["BUILD_DIGEST"]}'

for path in sorted(root.glob('docker-*/Dockerfile')):
    text = path.read_text()
    new_text = pattern.sub(replacement, text)
    if new_text != text:
        path.write_text(new_text)
PY
```

Expected:
- `rg -n 'chainargos/debian-blockchain-build:1\.0\.0@' docker-*/Dockerfile` returns no matches.
- `rg -n 'chainargos/debian-blockchain-build:1\.0\.0-1@' docker-*/Dockerfile` returns the expected set of Dockerfiles.

- [ ] **Step 6: Run final repository verification on structure, version metadata, and representative dry runs**

Run:

```bash
rg --files -g 'Dockerfile.amd64' -g 'Dockerfile.arm64'
./docker-build.rs debian-blockchain-build --dry-run
./docker-build.rs op-node --dry-run
./docker-build.rs bitcoin-core --dry-run
./docker-build.rs beacon-kit --dry-run
rg -n '^build = "1"$' docker-*/build.toml
rg -n '^build = "2"$' docker-*/build.toml
```

Expected:
- The `rg --files` command prints nothing.
- Every dry run prints `Dockerfile: Dockerfile`.
- `docker-debian-blockchain-base/build.toml` and `docker-debian-blockchain-build/build.toml` appear in the `build = "1"` output.
- Every leaf image package appears in the `build = "2"` output.

- [ ] **Step 7: Commit the release-version and digest refresh pass**

```bash
git add docker-*/Dockerfile docker-*/build.toml
git commit -m "Bump container revisions for Dockerfile unification"
```
