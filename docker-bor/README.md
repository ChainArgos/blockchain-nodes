# Extract config from docker image

```bash
docker run -it 0xpolygon/bor:2.0.0 dumpconfig
```

# Download genesis

```bash
curl -o genesis.json https://raw.githubusercontent.com/maticnetwork/bor/master/builder/files/genesis-mainnet-v1.json
```

# Latest mainnet config

```bash
curl -o config.toml https://raw.githubusercontent.com/maticnetwork/bor/refs/heads/master/packaging/templates/mainnet-v1/sentry/sentry/bor/pbss_config.toml
```
