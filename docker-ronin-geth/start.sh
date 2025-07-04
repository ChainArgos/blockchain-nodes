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

exec ronin \
  --datadir=/data/geth \
  --db.engine=pebble \
  --history.transactions=0 \
  --state.scheme=path \
  --syncmode=snap \
  --networkid=2020 \
  --discovery.dns=enrtree://AIGOFYDZH6BGVVALVJLRPHSOYJ434MPFVVQFXJDXHW5ZYORPTGKUI@nodes.roninchain.com \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.port=8745 \
  --http.api=eth,net,web3,ronin,consortium \
  --maxpeers=200 \
  --cache=8000 \
  --port=30311 \
  --v5disc \
  --nat=extip:"$PUBLIC_IP" \
  --miner.gaslimit=30000000 \
  --miner.gasreserve=10000000 \
  --txpool.nolocals=true \
  --txpool.pricelimit=20000000000
