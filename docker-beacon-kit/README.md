## mainnet config

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/berachain/beacon-kit/refs/heads/main/testing/networks/80094

mkdir -p config

curl -L "${CONFIG_BASE_URL}/app.toml" -o config/app.toml
curl -L "${CONFIG_BASE_URL}/client.toml" -o config/client.toml
curl -L "${CONFIG_BASE_URL}/config.toml" -o config/config.toml
curl -L "${CONFIG_BASE_URL}/genesis.json" -o config/genesis.json
curl -L "${CONFIG_BASE_URL}/kzg-trusted-setup.json" -o config/kzg-trusted-setup.json
```
