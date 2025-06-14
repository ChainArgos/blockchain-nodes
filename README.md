# blockchain-nodes

## TODO
- Movement (https://github.com/movementlabsxyz/movement)
- Aptos (https://aptos.dev/en/network/nodes/full-node)
- dYdX (https://docs.dydx.exchange/infrastructure_providers-validators/set_up_full_node)
- TON (https://docs.ton.org/participate/run-nodes/archive-node)
- Solana:
  - https://docs.solanalabs.com/operations/setup-an-rpc-node
  - https://medium.com/coinmonks/how-to-run-a-solana-rpc-node-214c418429e5

## Configuration

By default, all nodes are designed to store data in the `/data` volume, which is mounted to the host machine (default
path is `$HOME/<name_of_blockchain>`, for example for Bitcoin blockchain it will be `$HOME/bitcoin/`). This is done to 
make it easy to backup and restore the data. This can be changed by creating a copy of `.env.sample` and renaming it
to `.env`, by changing the root path for the particular blockchain (for example `BITCOIN_ROOT_DIR` env will manage 
the path to the root directory where Bitcoin data will be stored).

## How to run nodes?

This repo contains docker images for nodes that we run on our machines. We built our images for a few reasons:
- We used the same approach for the project's structure, we store all persistent data in `/data` volume.
- We added some utilities to work with RPC API inside the docker container, to make it easy to debug the state of the node.
- All images are designed to be full nodes (archive nodes) first, and tuned for maximum performance for such purpose.
- Most of our images are available for Linux AMD64 and ARM64 platforms, these images can be run on macOS with `Docker Desktop` (https://www.docker.com/products/docker-desktop/) or `OrbStack` (https://orbstack.dev). We suggest using OrbStack as it is much faster and using native virtualization.

We also provide a Docker Compose file to simplify the process of running a node.

For some blockchains (like Ethereum) we use different clients to compare the performance and storage usage. Below is an instruction on how to run nodes separated by different blockchains.

We also provide some helper scripts, which by default pull the latest image from the Docker Hub, and start it (if it was not started before) or stop the previous running node to restart it with the latest pulled image. After running the node in a daemon mode, it will stream the logs from the container to the stdout console to see the results.

### Bitcoin

For Bitcoin, only one client is available, which is `bitcoin-core`:

```bash
./restart-bitcoin-core.sh
```

### Ethereum

For Ethereum, there are two available configurations for how to run a full node.

To run Ethereum with a `geth` execution client (written in Go) and a `Lighthouse` consensus client (written in Rust) need to execute the following commands:

```bash
./restart-ethereum-geth.sh
./restart-ethereum-lighthouse.sh
```

### BSC

BSC is using a forked version of Ethereum's `geth` client to run it execute this command:

```bash
./restart-bsc-geth.sh
```

### Tron

There is only one client available for Tron and it's written in Java. It uses the old Java 8 and it doesn't work on ARM64 architecture (even though we provide that image), probably one day there be a solution for that, please follow this PR for ongoing discussion: https://github.com/tronprotocol/java-tron/pull/5845.

```bash
./restart-tron-java.sh
```

## How to build docker images?

First of all, you need to run the BuildKit docker container, it's necessary to build multi-arch images. Latest version of Docker
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
- https://ethereum.org/en/developers/docs/nodes-and-clients/run-a-node
- Besu/Teku clients: https://besu.hyperledger.org/public-networks/tutorials/besu-teku-mainnet

BSC:
- https://docs.bnbchain.org/docs/validator/fullnode/

Tron:
- https://developers.tron.network/docs/deploy-the-fullnode-or-supernode

Polygon:
- https://docs.polygon.technology/pos/how-to/full-node/full-node-binaries
- https://docs.polygon.technology/pos/how-to/full-node/full-node-docker

Avalanche:
- https://docs.avax.network/nodes/run-a-node/manually

Cardano:
- https://learn.lovelace.academy/getting-started/running-a-full-node

Dogecoin:
- https://dogecoin.com/dogepedia/how-tos/operating-a-node/

Scroll:
- https://docs.scroll.io/en/developers/guides/running-a-scroll-node

Optimism:
- https://docs.optimism.io/builders/node-operators/tutorials/mainnet

Ronin:
- https://docs.roninchain.com/basics/nodes
- https://docs.roninchain.com/validators/setup/mainnet/run-archive

Base: 
- https://github.com/base-org/node

Celo: 
- https://docs.celo.org/network/mainnet/run-full-node

Tezos:
- https://tezos.gitlab.io/user/history_modes.html

Ink:
- https://github.com/inkonchain/node

