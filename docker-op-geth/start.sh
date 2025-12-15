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
  optimism)
    http_port=8651
    sequencer_http=https://mainnet-sequencer.optimism.io
    op_network=op-mainnet
    p2p_port=30306
    discovery_port=30306
    ;;

  base)
    http_port=8648
    sequencer_http=https://mainnet-sequencer.base.org
    op_network=base-mainnet
    p2p_port=30304
    discovery_port=30304
    ;;

  ink)
    http_port=8652
    sequencer_http=https://rpc-gel.inkonchain.com
    op_network=ink-mainnet
    p2p_port=30307
    discovery_port=30307
    ;;

  unichain)
    http_port=8655
    sequencer_http=https://mainnet-sequencer.unichain.org
    op_network=unichain-mainnet
    p2p_port=30309
    discovery_port=30309
    ;;

  worldchain)
    http_port=8657
    sequencer_http=https://worldchain-mainnet-sequencer.g.alchemy.com
    op_network=worldchain-mainnet
    p2p_port=30313
    discovery_port=30313
    ;;

  hashkeychain)
    http_port=8662
    sequencer_http="https://mainnet.hsk.xyz"
    op_network=hashkeychain-mainnet
    p2p_port=30317
    discovery_port=30317
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
    exit 1
    ;;
esac

exec geth \
  --datadir=/data/op-geth \
  --db.engine=pebble \
  --history.transactions=0 \
  --state.scheme=path \
  --syncmode=snap \
  --http \
  --http.addr=0.0.0.0 \
  --http.corsdomain=* \
  --http.vhosts=* \
  --http.api=web3,debug,eth,txpool,net,rpc \
  --http.port="$http_port" \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.origins=* \
  --ws.api=web3,debug,eth,txpool,net,rpc \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --authrpc.addr=0.0.0.0 \
  --authrpc.vhosts=* \
  --authrpc.port=8551 \
  --maxpeers=200 \
  --cache=8000 \
  --rollup.sequencerhttp="$sequencer_http" \
  --rollup.halt=major \
  --rollup.disabletxpoolgossip=true \
  --op-network="$op_network" \
  --port="$p2p_port" \
  --discovery.port="$discovery_port" \
  --discv4=true \
  --discv5=true \
  --nat=extip:"$PUBLIC_IP" \
  --txpool.nolocals=true
