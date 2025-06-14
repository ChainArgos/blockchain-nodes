## celo mainnet config

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/celo-org/celo-l2-node-docker-compose/refs/heads/main/envs/mainnet/config

mkdir -p config

curl -L "${CONFIG_BASE_URL}/genesis.json" -o config/genesis.json
```
