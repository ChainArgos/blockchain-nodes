Generate basic configurations

```bash
docker run -v $HOME/heimdall:/heimdall-home:rw --entrypoint /usr/bin/heimdalld -it 0xpolygon/heimdall:1.2.0 init --home=/heimdall-home

cp $HOME/heimdall/config/config.toml config.toml
cp $HOME/heimdall/config/heimdall-config.toml heimdall-config.toml
```

Download genesis file

```bash
curl -o genesis.json https://raw.githubusercontent.com/maticnetwork/heimdall/master/builder/files/genesis-mainnet-v1.json
```
