#!/bin/bash
set -eou pipefail

if [ ! -d "/data/heimdalld" ]; then
  heimdalld init --chain=mainnet --home=/data/heimdalld --home-client=/data/heimdallcli

  sed -i 's|^seeds =.*|seeds = "1500161dd491b67fb1ac81868952be49e2509c9f@52.78.36.216:26656,dd4a3f1750af5765266231b9d8ac764599921736@3.36.224.80:26656,8ea4f592ad6cc38d7532aff418d1fb97052463af@34.240.245.39:26656,e772e1fb8c3492a9570a377a5eafdb1dc53cd778@54.194.245.5:26656,6726b826df45ac8e9afb4bdb2469c7771bd797f1@52.209.21.164:26656"|g' /data/heimdalld/config/config.toml
fi

echo "Initialization completed successfully"

exec "$@"
