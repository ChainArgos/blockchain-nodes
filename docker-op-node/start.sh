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
    export ca_op_geth_hostname="optimism-op-geth"
    ;;

  base)
    export ca_op_geth_hostname="base-op-geth"
    ;;

  ink)
    export ca_op_geth_hostname="ink-op-geth"
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

case $CA_NETWORK in

  optimism)
    exec op-node \
      --l1="${CA_ETHEREUM_RPC_URL}" \
      --l1.beacon="${CA_ETHEREUM_BEACON_URL}" \
      --l1.beacon-archiver="${CA_ETHEREUM_BEACON_ARCHIVER_URL}" \
      --l2=ws://"${ca_op_geth_hostname}":8551 \
      --l2.jwt-secret=/data/jwtsecret.hex \
      --l2.enginekind=geth \
      --network=op-mainnet \
      --syncmode=execution-layer \
      --rpc.addr=0.0.0.0
    ;;

  base)
    exec op-node \
      --l1="${CA_ETHEREUM_RPC_URL}" \
      --l1.beacon="${CA_ETHEREUM_BEACON_URL}" \
      --l1.beacon-archiver="${CA_ETHEREUM_BEACON_ARCHIVER_URL}" \
      --l2=ws://"${ca_op_geth_hostname}":8551 \
      --l2.jwt-secret=/data/jwtsecret.hex \
      --p2p.advertise.ip="$PUBLIC_IP" \
      --p2p.listen.ip=0.0.0.0 \
      --p2p.bootnodes=enr:-J24QNz9lbrKbN4iSmmjtnr7SjUMk4zB7f1krHZcTZx-JRKZd0kA2gjufUROD6T3sOWDVDnFJRvqBBo62zuF-hYCohOGAYiOoEyEgmlkgnY0gmlwhAPniryHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQKNVFlCxh_B-716tTs-h1vMzZkSs1FTu_OYTNjgufplG4N0Y3CCJAaDdWRwgiQG,enr:-J24QH-f1wt99sfpHy4c0QJM-NfmsIfmlLAMMcgZCUEgKG_BBYFc6FwYgaMJMQN5dsRBJApIok0jFn-9CS842lGpLmqGAYiOoDRAgmlkgnY0gmlwhLhIgb2Hb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJ9FTIv8B9myn1MWaC_2lJ-sMoeCDkusCsk4BYHjjCq04N0Y3CCJAaDdWRwgiQG,enr:-J24QDXyyxvQYsd0yfsN0cRr1lZ1N11zGTplMNlW4xNEc7LkPXh0NAJ9iSOVdRO95GPYAIc6xmyoCCG6_0JxdL3a0zaGAYiOoAjFgmlkgnY0gmlwhAPckbGHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJwoS7tzwxqXSyFL7g0JM-KWVbgvjfB8JA__T7yY_cYboN0Y3CCJAaDdWRwgiQG,enr:-J24QHmGyBwUZXIcsGYMaUqGGSl4CFdx9Tozu-vQCn5bHIQbR7On7dZbU61vYvfrJr30t0iahSqhc64J46MnUO2JvQaGAYiOoCKKgmlkgnY0gmlwhAPnCzSHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQINc4fSijfbNIiGhcgvwjsjxVFJHUstK9L1T8OTKUjgloN0Y3CCJAaDdWRwgiQG,enr:-J24QG3ypT4xSu0gjb5PABCmVxZqBjVw9ca7pvsI8jl4KATYAnxBmfkaIuEqy9sKvDHKuNCsy57WwK9wTt2aQgcaDDyGAYiOoGAXgmlkgnY0gmlwhDbGmZaHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQIeAK_--tcLEiu7HvoUlbV52MspE0uCocsx1f_rYvRenIN0Y3CCJAaDdWRwgiQG \
      --verifier.l1-confs=4 \
      --rollup.load-protocol-versions=true \
      --network=base-mainnet \
      --rpc.addr=0.0.0.0
    ;;

  ink)
    exec op-node \
      --l1="${CA_ETHEREUM_RPC_URL}" \
      --l1.beacon="${CA_ETHEREUM_BEACON_URL}" \
      --l1.beacon-archiver="${CA_ETHEREUM_BEACON_ARCHIVER_URL}" \
      --l2=ws://"${ca_op_geth_hostname}":8551 \
      --l2.jwt-secret=/data/jwtsecret.hex \
      --p2p.advertise.ip="$PUBLIC_IP" \
      --p2p.listen.ip=0.0.0.0 \
      --p2p.bootnodes="enr:-Iu4QCqTQZVBnbPWXcdUxcakGoCCzCFr5vVzDfNTOr-Pi3KaOJZMXlnqTR9r9p4EemXS8fS59EdQaX8qrkyE01nvsNcBgmlkgnY0gmlwhCIgwYaJc2VjcDI1NmsxoQMW3w0F1AibYelKqJUKaie5RuKc7S9sPfWvH4lSJw4Fo4N0Y3CCIyuDdWRwgiMs" \
      --p2p.static="/ip4/34.32.193.134/tcp/9003/p2p/16Uiu2HAmECGb1vmBKhgxVHzX2aYkPcmV8CZjpPxrNkRiFA1wa3CN" \
      --p2p.scoring=none \
      --rollup.config=/ink/rollup.json \
      --rollup.load-protocol-versions=true \
      --syncmode=consensus-layer \
      --rpc.addr=0.0.0.0
    ;;

esac
