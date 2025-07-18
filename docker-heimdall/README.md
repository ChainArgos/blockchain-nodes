Generate basic configurations

```bash
rm -rf $HOME/heimdall

docker run -v $HOME/heimdall:/heimdall-home:rw --entrypoint /usr/bin/heimdalld -it 0xpolygon/heimdall-v2:0.2.9 init chainargos --home=/heimdall-home --chain-id heimdallv2-137

mkdir -p config

cp $HOME/heimdall/config/app.toml config/app.toml
cp $HOME/heimdall/config/client.toml config/client.toml
cp $HOME/heimdall/config/config.toml config/config.toml
cp $HOME/heimdall/config/node_key.json config/node_key.json
cp $HOME/heimdall/config/priv_validator_key.json config/priv_validator_key.json
```

Download genesis file

```bash
export CONFIG_BASE_URL=https://storage.googleapis.com/mainnet-heimdallv2-genesis

mkdir -p config

curl -L "${CONFIG_BASE_URL}/migrated_dump-genesis.json" -o config/genesis.json

cd config

xz -9 -k genesis.json
```
