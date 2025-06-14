# Extract config from docker image

```bash
docker run -it 0xpolygon/bor:2.0.0 dumpconfig
```

# Latest mainnet config

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/maticnetwork/bor/refs/heads/master/packaging/templates/mainnet-v1/sentry/sentry/bor

mkdir -p config

curl -L "${CONFIG_BASE_URL}/pbss_config.toml" -o config/config.toml
```
