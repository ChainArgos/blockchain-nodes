#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

docker stop -s 9 unichain-op-node
docker rm unichain-op-node

docker stop -s 9 unichain-op-geth
docker rm unichain-op-geth

rm -rf /blockchain/disk1/unichain/
ls -la /blockchain/disk1
