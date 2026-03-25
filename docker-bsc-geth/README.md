```bash
curl -L https://github.com/bnb-chain/bsc/releases/download/v1.7.2/mainnet.zip -o mainnet.zip
unzip mainnet.zip
mv mainnet/config.toml config/
mv mainnet/genesis.json config/
rm mainnet.zip
```
