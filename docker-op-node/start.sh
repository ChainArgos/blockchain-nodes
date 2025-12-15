#!/bin/bash
set -eou pipefail

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

if [[ -z "${CA_ETHEREUM_BEACON_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_BEACON_URL is not set"
  exit 1
fi

if [[ -z "${CA_ETHEREUM_BEACON_ARCHIVER_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_BEACON_ARCHIVER_URL is not set"
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

mkdir -p /data/op-node

cd /data/op-node

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

case $CA_NETWORK in
  optimism)
    ca_op_geth_hostname="optimism-op-geth"
    p2p_listen_tcp=9222
    network=op-mainnet
    ;;

  base)
    ca_op_geth_hostname="base-op-geth"
    p2p_listen_tcp=9223
    network=base-mainnet
    ;;

  ink)
    ca_op_geth_hostname="ink-op-geth"
    p2p_listen_tcp=9224
    network=ink-mainnet
    ;;

  unichain)
    ca_op_geth_hostname="unichain-op-geth"
    p2p_listen_tcp=9225
    network=unichain-mainnet
    ;;

  worldchain)
    ca_op_geth_hostname="worldchain-op-geth"
    p2p_listen_tcp=9227
    network=worldchain-mainnet
    ;;

  fraxtal)
    ca_op_geth_hostname="fraxtal-op-geth"
    p2p_listen_tcp=9228
    network=fraxtal-mainnet
    ;;

  hashkeychain)
    ca_op_geth_hostname="hashkeychain-op-geth"
    p2p_listen_tcp=9229
    network=hashkeychain-mainnet
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
    exit 1
    ;;
esac

# wait until local execution client comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "http://${ca_op_geth_hostname}:8551")" -eq 401 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

exec op-node \
  --l1="${CA_ETHEREUM_RPC_URL}" \
  --l1.trustrpc \
  --l1.beacon="${CA_ETHEREUM_BEACON_URL}" \
  --l1.beacon-archiver="${CA_ETHEREUM_BEACON_ARCHIVER_URL}" \
  --l2=http://"${ca_op_geth_hostname}":8551 \
  --l2.jwt-secret=/data/jwtsecret.hex \
  --l2.enginekind=geth \
  --p2p.advertise.ip="$PUBLIC_IP" \
  --p2p.listen.ip=0.0.0.0 \
  --p2p.listen.tcp="$p2p_listen_tcp" \
  --p2p.scoring=none \
  --verifier.l1-confs=4 \
  --rollup.load-protocol-versions=true \
  --network="$network" \
  --syncmode=execution-layer \
  --rpc.addr=0.0.0.0
