#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

docker stop -s 9 base-op-node
docker rm base-op-node

docker stop -s 9 base-op-geth
docker rm base-op-geth

rm -rf /blockchain/disk1/base/
ls -la /blockchain/disk1
