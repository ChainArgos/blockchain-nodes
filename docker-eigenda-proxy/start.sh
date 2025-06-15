#!/bin/bash
set -eou pipefail

if [[ -z "${CA_ETHEREUM_RPC_URL}" ]]; then
  echo "ERROR: CA_ETHEREUM_RPC_URL is not set"
  exit 1
fi

if [[ -z "${CA_NETWORK}" ]]; then
  echo "ERROR: CA_NETWORK is not set"
  exit 1
fi

case $CA_NETWORK in

  celo)
    exec eigenda-proxy \
      --addr=0.0.0.0 \
      --port=4242 \
      --eigenda.g1-path=/var/lib/eigenda-proxy/resources/g1.point \
      --eigenda.g2-path=/var/lib/eigenda-proxy/resources/g2.point \
      --eigenda.g2-path-trailing=/var/lib/eigenda-proxy/resources/g2.trailing.point \
      --eigenda.disperser-rpc=disperser.eigenda.xyz:443 \
      --eigenda.eth-rpc="${CA_ETHEREUM_RPC_URL}" \
      --eigenda.signer-private-key-hex=0123456789012345678901234567890123456789012345678901234567890123 \
      --eigenda.svc-manager-addr=0x870679e138bcdf293b7ff14dd44b70fc97e12fc0 \
      --eigenda.status-query-timeout=45m \
      --eigenda.disable-tls=false \
      --eigenda.confirmation-depth=1 \
      --eigenda.max-blob-length=16MiB \
      --storage.backends-to-enable=V1,V2 \
      --eigenda.v2.disperser-rpc=disperser.eigenda.xyz:443 \
      --eigenda.v2.eth-rpc="${CA_ETHEREUM_RPC_URL}" \
      --eigenda.v2.disable-tls=false \
      --eigenda.v2.blob-certified-timeout=2m \
      --eigenda.v2.blob-status-poll-interval=1s \
      --eigenda.v2.contract-call-timeout=5s \
      --eigenda.v2.relay-timeout=5s \
      --eigenda.v2.blob-version=0 \
      --eigenda.v2.max-blob-length=16MiB \
      --eigenda.v2.cert-verifier-addr=0xE1Ae45810A738F13e70Ac8966354d7D0feCF7BD6 \
      --eigenda.v2.signer-payment-key-hex=0123456789012345678901234567890123456789012345678901234567890123 \
      --eigenda.v2.service-manager-addr=0x870679e138bcdf293b7ff14dd44b70fc97e12fc0 \
      --eigenda.v2.bls-operator-state-retriever-addr=0xEC35aa6521d23479318104E10B4aA216DBBE63Ce \
      --s3.credential-type=public \
      --s3.bucket=eigenda-proxy-cache-mainnet \
      --s3.path=blobs/ \
      --s3.endpoint=storage.googleapis.com \
      --storage.fallback-targets=s3
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
    exit 1
    ;;

esac
