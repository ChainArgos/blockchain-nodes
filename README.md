# blockchain-nodes

## How to build docker images?

First of all you need run BuildKit docker container, it's necessary to build multi-arch images. Latest version of Docker
already integrated it as command `buildx`. Run the following command to create a new builder and set it as default:

```bash
docker buildx create --name "buildx" --driver docker-container --use
docker buildx use buildx
```

Inside the specific project folder, just run the `build.sh` command to build the image, for example for Bitcoin Core:

```bash
./docker-bitcoin-core/build.sh
```

## How to run full nodes (official wiki)

Ethereum:
- https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node/
- Besu/Teku clients: https://besu.hyperledger.org/public-networks/tutorials/besu-teku-mainnet

BSC:
- https://docs.bnbchain.org/docs/validator/fullnode/

Tron:
- https://developers.tron.network/docs/deploy-the-fullnode-or-supernode
