# Extract config from docker image

```bash
docker run -it 0xpolygon/bor:2.2.10 dumpconfig
```

# Latest mainnet config

> **Note:** When updating the version in `build.toml`, verify the config is still up to date and run `sync-config.rs` to pull the latest config.

```bash
rust-script sync-config.rs
```
