## mainnet config

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/berachain/beacon-kit/refs/heads/main/testing/networks/80094

mkdir -p config

curl -L "${CONFIG_BASE_URL}/eth-genesis.json" -o config/eth-genesis.json
curl -L "${CONFIG_BASE_URL}/el-peers.txt" -o config/el-peers.txt
```
