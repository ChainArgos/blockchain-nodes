## fraxtal mainnet config

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/FraxFinance/fraxtal-node/refs/heads/master/mainnet

mkdir -p config

curl -L "${CONFIG_BASE_URL}/rollup.json" -o config/rollup.json
```
