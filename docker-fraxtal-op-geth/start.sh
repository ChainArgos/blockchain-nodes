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

exec geth \
  --authrpc.addr=0.0.0.0 \
  --authrpc.jwtsecret=/data/jwtsecret.hex \
  --authrpc.port=8551 \
  --authrpc.vhosts=* \
  --bootnodes=enr:-J24QI8QR7VIgvQFuvLl09b9ocugoQ1WkS_AOMWKFgNX48-4P1hjgDKGeMFXZmKtfjYA2aEehxKT066riaktnxhh92OGAY5Sw_QsgmlkgnY0gmlwhCztZu2Hb3BzdGFja4P8AQCJc2VjcDI1NmsxoQM2KM0mkdH97Ze8AqwxLeqc934PKj8-xoKsyP6mAptWwIN0Y3CCdl2DdWRwgnZd,enr:-J24QGD1J-g2EPY9b7XiuwLhIoGocVp2qx2gWSfDI_CdftiPSHlgi7G6LtzkQlDskuSvRj4OXTg3vXLISubphXNNhqyGAY5Sw8GxgmlkgnY0gmlwhCzW_iGHb3BzdGFja4P8AQCJc2VjcDI1NmsxoQPvMYlJHJUsEyciuJCTkKHLE2ogZ6cs2xuPI28CGq0CTIN0Y3CCdl2DdWRwgnZd,enr:-J24QCA5I3xroUXt7Ge_Kf04VCRBnI-GbZeyBxOkkpIDGGLrVsonrbngQG1hAEnufRb1TgS6sNFCGtaZ2ZpRx7AgciGGAY5SxEy0gmlkgnY0gmlwhCLzRQyHb3BzdGFja4P8AQCJc2VjcDI1NmsxoQOaHzrtPQWYcwAcFJWFrbGlbNUsBC0VEhCcH02RbgEIwIN0Y3CCdl2DdWRwgnZd \
  --cache=8000 \
  --datadir=/data/op-geth \
  --db.engine=pebble \
  --discovery.port=30316 \
  --discv4=true \
  --discv5=true \
  --history.logs=0 \
  --history.transactions=0 \
  --http \
  --http.addr=0.0.0.0 \
  --http.api=web3,debug,eth,txpool,net,rpc \
  --http.corsdomain=* \
  --http.port=8661 \
  --http.vhosts=* \
  --maxpeers=50 \
  --nat=extip:"$PUBLIC_IP" \
  --networkid=252 \
  --override.canyon=0 \
  --override.ecotone=1717009201 \
  --override.fjord=1733947201 \
  --override.granite=1738958401 \
  --override.holocene=1744052401 \
  --override.isthmus=1755716401 \
  --port=30316 \
  --rollup.disabletxpoolgossip=true \
  --rollup.halt=major \
  --rollup.sequencerhttp=https://rpc.mainnet.frax.com \
  --state.scheme=path \
  --syncmode=snap \
  --txpool.nolocals=true \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.api=web3,debug,eth,txpool,net,rpc \
  --ws.origins=*
