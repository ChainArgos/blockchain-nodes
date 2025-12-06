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

export EL_BOOTNODES=$(grep '^enode://' "/config/berachain/el-bootnodes.txt"| tr '\n' ',' | sed 's/,$//')
export EL_PEERS=$(grep '^enode://' "/config/berachain/el-peers.txt"| tr '\n' ',' | sed 's/,$//')

exec bera-reth node \
    --identity=chainargos \
    --authrpc.jwtsecret=/data/jwtsecret.hex \
    --chain=/config/berachain/genesis.json \
    --datadir=/data/reth \
    --port=30308 \
    --discovery.port=30308 \
    --full \
    --http \
    --http.addr=0.0.0.0 \
    --http.port=8654 \
    --http.corsdomain="*" \
    --bootnodes=$EL_BOOTNODES \
    --trusted-peers=$EL_PEERS \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port=8551 \
    --engine.persistence-threshold=0 \
    --engine.memory-block-buffer-target=0 \
    --enable-discv5-discovery \
    --nat=extip:"$PUBLIC_IP" \
    --txpool.nolocals
