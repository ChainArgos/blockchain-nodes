## celo mainnet config

```bash
export CONFIG_BASE_URL=https://storage.googleapis.com/cel2-rollup-files/celo

mkdir -p config/celo

curl -L "${CONFIG_BASE_URL}/rollup.json" -o config/celo/rollup.json
```
