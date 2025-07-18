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

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

until [ "$(curl -s -w '%{http_code}' -o /dev/null "${CA_ETHEREUM_RPC_URL}")" -eq 200 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

if [[ -z "${CA_ETHEREUM_BEACON_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_BEACON_URL is not set"
  exit 1
fi

exec geth \
  --datadir=/data/geth \
  --scroll \
  --syncmode=snap \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8650 \
  --http.api=eth,net,web3,debug,scroll \
  --cache.noprefetch \
  --cache.snapshot=0 \
  --l1.endpoint="${CA_ETHEREUM_RPC_URL}" \
  --da.blob.beaconnode="${CA_ETHEREUM_BEACON_URL}" \
  --rollup.verify \
  --txlookuplimit=0 \
  --v5disc \
  --nat=extip:"$PUBLIC_IP" \
  --txpool.nolocals \
  --snapshot=false \
  --gpo.maxprice=500000000 \
  --gpo.congestionthreshold=1000
