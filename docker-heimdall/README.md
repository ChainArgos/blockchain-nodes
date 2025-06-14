Generate basic configurations

```bash
docker run -v $HOME/heimdall:/heimdall-home:rw --entrypoint /usr/bin/heimdalld -it 0xpolygon/heimdall:1.2.3 init --home=/heimdall-home

mkdir -p config

cp $HOME/heimdall/config/config.toml config/config.toml
cp $HOME/heimdall/config/heimdall-config.toml config/heimdall-config.toml
```

Download genesis file

```bash
export CONFIG_BASE_URL=https://raw.githubusercontent.com/maticnetwork/heimdall/master/builder/files

mkdir -p config

curl -L "${CONFIG_BASE_URL}/genesis-mainnet-v1.json" -o config/genesis.json
```
