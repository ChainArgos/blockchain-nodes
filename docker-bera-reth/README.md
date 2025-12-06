## berachain mainnet config

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/berachain/beacon-kit/refs/heads/main/testing/networks/80094

mkdir -p config/berachain

curl -L "${CONFIG_BASE_URL}/eth-genesis.json" -o config/berachain/genesis.json
curl -L "${CONFIG_BASE_URL}/el-bootnodes.txt" -o config/berachain/el-bootnodes.txt
curl -L "${CONFIG_BASE_URL}/el-peers.txt" -o config/berachain/el-peers.txt
```
