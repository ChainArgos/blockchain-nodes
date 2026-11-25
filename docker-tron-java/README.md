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

## gRPC

The packaged configuration enables the gRPC APIs: the full node on 50051
(`Wallet`, `Database`, `WalletExtension`), the solidity node on 50061
(`WalletSolidity`) and PBFT on 50071. `docker-compose.yml` publishes 50051 and
50061 only.

java-tron has no gRPC authentication, and the full-node service can broadcast
transactions. Docker publishes on every host address, so restrict these ports
with a host firewall to trusted clients before publishing them.

The solidity service has no range call: it serves `GetBlockByNum2` and
`GetTransactionInfoByBlockNum` per block. `GetBlockByLimitNext` and
`GetBlockByLimitNext2` (at most 100 blocks per call) exist on the full-node
service only. The full node runs ahead of the solidity node, which serves only
solidified blocks.

`node.rpc.maxMessageSize` (default 4 MiB) is applied as the server's
`maxInboundMessageSize`, so it limits requests only. Responses have no
server-side size limit; a client must raise its own decode limit. java-tron
never sets a response compressor, so gRPC gzip is not available.
