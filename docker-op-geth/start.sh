#!/bin/bash
set -eou pipefail

echo "CA_NETWORK: ${CA_NETWORK}"

get_public_ip() {
  # Define a list of HTTP-based providers
  local PROVIDERS=(
    "http://ifconfig.me"
    "http://api.ipify.org"
    "http://ipecho.net/plain"
    "http://v4.ident.me"
  )
  # Iterate through the providers until an IP is found or the list is exhausted
  for provider in "${PROVIDERS[@]}"; do
    local IP
    IP=$(curl -s "$provider")
    # Check if IP contains a valid format (simple regex for an IPv4 address)
    if [[ $IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "$IP"
      return 0
    fi
  done
  return 1
}

# public-facing P2P node, advertise public IP address
if PUBLIC_IP=$(get_public_ip); then
  echo "Fetched public IP is: $PUBLIC_IP"
else
  echo "ERROR: Could not retrieve public IP."
  exit 1
fi

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

case $CA_NETWORK in

  optimism)
    exec geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --verbosity=3 \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --http.api=web3,debug,eth,net,engine \
      --http.port=8651 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=debug,eth,net,engine \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.port=8551 \
      --syncmode=snap \
      --rollup.disabletxpoolgossip=true \
      --rollup.sequencerhttp=https://mainnet-sequencer.optimism.io/ \
      --op-network=op-mainnet \
      --port=30306 \
      --discovery.port=30306 \
      --nat=extip:"$PUBLIC_IP"
    ;;

  base)
    exec geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --verbosity=3 \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --http.api=web3,debug,eth,net,engine \
      --http.port=8648 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=debug,eth,net,engine \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.port=8551 \
      --syncmode=full \
      --gcmode=full \
      --maxpeers=100 \
      --rollup.sequencerhttp=https://mainnet-sequencer.base.org \
      --rollup.halt=major \
      --rollup.disabletxpoolgossip=true \
      --op-network=base-mainnet \
      --port=30304 \
      --discovery.port=30304 \
      --nat=extip:"$PUBLIC_IP"
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct"
    exit 1
    ;;

esac
