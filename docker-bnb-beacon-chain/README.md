## BNB Beacon Chain (legacy Binance Chain) mainnet config

This is the legacy Tendermint-based BNB Beacon Chain (formerly Binance Chain).
The chain has been sunset as of block height 384544850 (Nov 2024, BEP333).

Binary and config sourced from [v0.10.24](https://github.com/bnb-chain/node/releases/tag/v0.10.24) (final release).

> **Note:** Only amd64 is supported — the project does not publish arm64 binaries.

```bash
mkdir -p config

curl -L https://github.com/bnb-chain/node/releases/download/v0.10.24/mainnet_config.zip -o mainnet_config.zip
unzip mainnet_config.zip
mv asset/mainnet/config.toml config/
mv asset/mainnet/app.toml config/
mv asset/mainnet/genesis.json config/
rm -rf mainnet_config.zip asset
```
