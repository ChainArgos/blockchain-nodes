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

cp /config/app.toml /data/beacon-kit/config/app.toml
cp /config/client.toml /data/beacon-kit/config/client.toml
cp /config/genesis.json /data/beacon-kit/config/genesis.json
cp /config/kzg-trusted-setup.json /data/beacon-kit/config/kzg-trusted-setup.json

PUBLIC_IP=${PUBLIC_IP} gomplate -f /config/config.toml -o /data/beacon-kit/config/config.toml

exec beacond \
  start \
  --home /data/beacon-kit
