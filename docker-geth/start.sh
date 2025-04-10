#!/bin/bash
set -eou pipefail

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

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

case $CA_NETWORK in

  ethereum)
    exec geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --history.transactions=0 \
      --state.scheme=path \
      --syncmode=snap \
      --mainnet \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --port=30303 \
      --discovery.port=30303 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  berachain)
    EL_BOOTNODES=$(grep '^enode://' "/config/berachain/el-bootnodes.txt"| tr '\n' ',' | sed 's/,$//')

    exec geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --history.transactions=0 \
      --state.scheme=path \
      --syncmode=full \
      --bootnodes="$EL_BOOTNODES" \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --http.port=8654 \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --port=30308 \
      --discovery.port=30308 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
    exit 1
    ;;

esac
