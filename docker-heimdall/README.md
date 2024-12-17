Generate basic configurations

```bash
docker run -v $HOME/heimdall:/heimdall-home:rw --entrypoint /usr/bin/heimdalld -it 0xpolygon/heimdall:1.0.10 init --home=/heimdall-home
```

Download genesis file

```bash
curl -o genesis.json https://raw.githubusercontent.com/maticnetwork/heimdall/master/builder/files/genesis-mainnet-v1.json
```
