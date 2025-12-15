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

export ca_op_geth_hostname="fraxtal-op-geth"

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
  --p2p.listen.tcp=9228 \
  --p2p.scoring=none \
  --p2p.bootnodes=enr:-J24QPGxmNmQ6Gsofjwnaaqt-RvC-2te44hHSU_wFGvCBpdnGnAuW0hKBCwzarXEmLN0TfwilwX3xS8xjEd9sQRqKXqGAY1ok0P3gmlkgnY0gmlwhDa-pcmHb3BzdGFja4P8AQCJc2VjcDI1NmsxoQJA0echCE64KVt7m1lHfRF9_QgYxqIOSoPZ1UHcEArDu4N0Y3CCJAaDdWRwgiQG,enr:-J24QHPYu7uUXH4LCJ_pjHMD3fYhluZEgFRlewqOFFcja7ACaTDp4zG4GZBJdTPmLjsqskhTQa5ldKiVu4ypZYMzR_uGAY1ok_ABgmlkgnY0gmlwhCLvv1KHb3BzdGFja4P8AQCJc2VjcDI1NmsxoQOEemNzZL5buGmwlN2naXLtz4nauCqBFeFxdmi4RL4rDIN0Y3CCJAaDdWRwgiQG,enr:-J24QBujtfGNIiE6GJrCgXEKJMs1F11wd4Y8Uvx7ZFn3Z1tyR0erNcpiW5EYIQEKQX0kL9PLJUDHWZFiaHWOTBvFg5aGAY1ok5p8gmlkgnY0gmlwhDbD-tqHb3BzdGFja4P8AQCJc2VjcDI1NmsxoQLunzKLYJLvy6cWWkLgSSdLlILgSohrV8RT3tlKGwHBi4N0Y3CCJAaDdWRwgiQG \
  --rollup.config=/config/rollup.json \
  --syncmode=execution-layer \
  --rpc.addr=0.0.0.0 \
  --altda.da-server=https://da-rpc.mainnet.frax.com \
