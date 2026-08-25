## tron mainnet config

> **Note:** When updating the version in `build.toml`, verify the config is still up to date and run `sync-config.rs` to pull the latest config.

```bash
rust-script sync-config.rs
```

## Runtime defaults

The packaged mainnet configuration uses RocksDB. Prometheus metrics and event
subscriptions are disabled by default, and legacy InfluxDB settings are not
included. JSON-RPC request, response, batch, and filter limits follow the
upstream defaults.
