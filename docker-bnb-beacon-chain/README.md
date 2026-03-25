## BNB Beacon Chain (legacy Binance Chain) mainnet config

This is the legacy Tendermint-based BNB Beacon Chain (formerly Binance Chain).
The chain has been sunset as of block height 384544850 (Nov 2024, BEP333).

Binary and config sourced from [v0.10.24](https://github.com/bnb-chain/node/releases/tag/v0.10.24) (final release).

> **Note:** Only amd64 is supported — the project does not publish arm64 binaries.

> **Note:** When updating the version in `build.toml`, verify the config is still up to date and run `sync-config.rs` to pull the latest config.

```bash
rust-script sync-config.rs
```
