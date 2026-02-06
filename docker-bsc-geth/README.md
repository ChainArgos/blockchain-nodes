```bash
curl -L https://github.com/bnb-chain/bsc/releases/download/v1.6.6/mainnet.zip -o mainnet.zip
unzip mainnet.zip
mv mainnet/config.toml config/
mv mainnet/genesis.json config/
rm mainnet.zip
```
