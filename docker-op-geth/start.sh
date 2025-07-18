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
      --http.api=web3,debug,eth,txpool,net,admin,rpc \
      --http.port=8651 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=web3,debug,eth,txpool,net,admin,rpc \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --rollup.sequencerhttp=https://mainnet-sequencer.optimism.io \
      --rollup.halt=major \
      --rollup.disabletxpoolgossip=true \
      --op-network=op-mainnet \
      --port=30306 \
      --discovery.port=30306 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  base)
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
      --http.api=web3,debug,eth,txpool,net,admin,rpc \
      --http.port=8648 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=web3,debug,eth,txpool,net,admin,rpc \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --rollup.sequencerhttp=https://mainnet-sequencer.base.org \
      --rollup.halt=major \
      --rollup.disabletxpoolgossip=true \
      --op-network=base-mainnet \
      --port=30304 \
      --discovery.port=30304 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  ink)
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
      --http.api=web3,debug,eth,txpool,net,admin,rpc \
      --http.port=8652 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=web3,debug,eth,txpool,net,admin,rpc \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --rollup.sequencerhttp=https://rpc-gel.inkonchain.com \
      --rollup.halt=major \
      --rollup.disabletxpoolgossip=true \
      --op-network=ink-mainnet \
      --port=30307 \
      --discovery.port=30307 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  unichain)
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
      --http.api=web3,debug,eth,txpool,net,admin,rpc \
      --http.port=8655 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=web3,debug,eth,txpool,net,admin,rpc \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --rollup.sequencerhttp=https://mainnet-sequencer.unichain.org \
      --rollup.halt=major \
      --rollup.disabletxpoolgossip=true \
      --op-network=unichain-mainnet \
      --port=30309 \
      --discovery.port=30309 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  worldchain)
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
      --http.api=web3,debug,eth,txpool,net,admin,rpc \
      --http.port=8657 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.origins=* \
      --ws.api=web3,debug,eth,txpool,net,admin,rpc \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --rollup.sequencerhttp=https://worldchain-mainnet-sequencer.g.alchemy.com \
      --rollup.halt=major \
      --rollup.disabletxpoolgossip=true \
      --op-network=worldchain-mainnet \
      --port=30313 \
      --discovery.port=30313 \
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
