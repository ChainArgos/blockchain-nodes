#!/bin/bash
set -eou pipefail

if [[ -z "${ETHEREUM_EXECUTION_HOSTNAME}" ]]; then
  echo "ERROR: ETHEREUM_EXECUTION_HOSTNAME is not set"
  exit 1
fi

if [[ -z "${ETHEREUM_CONSENSUS_HOSTNAME}" ]]; then
  echo "ERROR: ETHEREUM_CONSENSUS_HOSTNAME is not set"
  exit 1
fi

if [[ -z "${OP_NODE_L1_BEACON_URL}" ]]; then
  echo "ERROR: OP_NODE_L1_BEACON_URL is not set"
  exit 1
fi

if [[ -z "${OP_NODE_L1_BEACON_ARCHIVER_URL}" ]]; then
  echo "ERROR: OP_NODE_L1_BEACON_ARCHIVER_URL is not set"
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

# wait until local execution client comes up (authed so will return 401 without token)
until [ "$(curl -s -w '%{http_code}' -o /dev/null "http://base-op-geth:38551")" -eq 401 ]; do
  echo "waiting for execution (geth) client to be ready"
  sleep 5
done

mkdir -p /data/op-node

cd /data/op-node

exec op-node \
  --l1=http://"${ETHEREUM_EXECUTION_HOSTNAME}":8545 \
  --l1.beacon="$OP_NODE_L1_BEACON_URL" \
  --l1.beacon-archiver="$OP_NODE_L1_BEACON_ARCHIVER_URL" \
  --l2=ws://base-op-geth:38551 \
  --l2.jwt-secret=/data/jwtsecret.hex \
  --p2p.advertise.ip="$PUBLIC_IP" \
  --p2p.listen.ip=0.0.0.0 \
  --p2p.bootnodes=enr:-J24QNz9lbrKbN4iSmmjtnr7SjUMk4zB7f1krHZcTZx-JRKZd0kA2gjufUROD6T3sOWDVDnFJRvqBBo62zuF-hYCohOGAYiOoEyEgmlkgnY0gmlwhAPniryHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQKNVFlCxh_B-716tTs-h1vMzZkSs1FTu_OYTNjgufplG4N0Y3CCJAaDdWRwgiQG,enr:-J24QH-f1wt99sfpHy4c0QJM-NfmsIfmlLAMMcgZCUEgKG_BBYFc6FwYgaMJMQN5dsRBJApIok0jFn-9CS842lGpLmqGAYiOoDRAgmlkgnY0gmlwhLhIgb2Hb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJ9FTIv8B9myn1MWaC_2lJ-sMoeCDkusCsk4BYHjjCq04N0Y3CCJAaDdWRwgiQG,enr:-J24QDXyyxvQYsd0yfsN0cRr1lZ1N11zGTplMNlW4xNEc7LkPXh0NAJ9iSOVdRO95GPYAIc6xmyoCCG6_0JxdL3a0zaGAYiOoAjFgmlkgnY0gmlwhAPckbGHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJwoS7tzwxqXSyFL7g0JM-KWVbgvjfB8JA__T7yY_cYboN0Y3CCJAaDdWRwgiQG,enr:-J24QHmGyBwUZXIcsGYMaUqGGSl4CFdx9Tozu-vQCn5bHIQbR7On7dZbU61vYvfrJr30t0iahSqhc64J46MnUO2JvQaGAYiOoCKKgmlkgnY0gmlwhAPnCzSHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQINc4fSijfbNIiGhcgvwjsjxVFJHUstK9L1T8OTKUjgloN0Y3CCJAaDdWRwgiQG,enr:-J24QG3ypT4xSu0gjb5PABCmVxZqBjVw9ca7pvsI8jl4KATYAnxBmfkaIuEqy9sKvDHKuNCsy57WwK9wTt2aQgcaDDyGAYiOoGAXgmlkgnY0gmlwhDbGmZaHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQIeAK_--tcLEiu7HvoUlbV52MspE0uCocsx1f_rYvRenIN0Y3CCJAaDdWRwgiQG
  --verifier.l1-confs=4 \
  --rollup.load-protocol-versions=true \
  --network=base-mainnet \
  --rpc.addr=0.0.0.0
