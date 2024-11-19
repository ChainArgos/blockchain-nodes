#!/bin/bash
set -eou pipefail

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

exec geth \
  --datadir=/data/geth \
  --db.engine=pebble \
  --verbosity=3 \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8648 \
  --http.api=web3,debug,eth,net,engine \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=38551 \
  --authrpc.vhosts=* \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --syncmode=full \
  --gcmode=full \
  --maxpeers=100 \
  --rollup.sequencerhttp=https://mainnet-sequencer.base.org \
  --rollup.halt=major \
  --op-network=base-mainnet \
  --port=30304 \
  --rollup.disabletxpoolgossip=true \
  --nat=extip:"$PUBLIC_IP"
