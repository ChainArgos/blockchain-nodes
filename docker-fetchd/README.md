## fetchhub-4 mainnet config

```bash
mkdir -p config

curl -L https://raw.githubusercontent.com/fetchai/genesis-fetchhub/fetchhub-4/fetchhub-4/data/genesis_migrated_5300200.json -o config/genesis.json
xz -9 config/genesis.json
```
