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

  ethereum)
    exec geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --history.transactions=0 \
      --state.scheme=path \
      --syncmode=snap \
      --mainnet \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --port=30303 \
      --discovery.port=30303 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  berachain)
    EL_BOOTNODES=$(grep '^enode://' "/config/berachain/el-bootnodes.txt"| tr '\n' ',' | sed 's/,$//')

    exec geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --history.transactions=0 \
      --state.scheme=path \
      --syncmode=full \
      --bootnodes="$EL_BOOTNODES" \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --http.port=8654 \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --port=30308 \
      --discovery.port=30308 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true
    ;;

  linea)
    exec /opt/geth-1.13/geth \
      --datadir=/data/geth \
      --db.engine=pebble \
      --history.transactions=0 \
      --state.scheme=path \
      --syncmode=snap \
      --networkid=59144 \
      --bootnodes="enode://069800db9e6e0ec9cadca670994ef1aea2cfd3d88133e63ecadbc1cdbd1a5847b09838ee08d8b5f02a9c32ee13abeb4d4104bb5514e5322c9d7ee19f41ff3e51@3.132.73.210:31002,enode://a8e03a71eab12ec4b47bb6e19169d8e4dc7a58373a2476969bbe463f2dded6003037fa4dd5f71e15027f7fc8d7340956fbbefed67ddd116ac19a7f74da034b61@3.132.73.210:31003,enode://97706526cf79df9d930003644f9156805f6c8bd964fc79e083444f7014ce10c9bdd2c5049e63b58040dca1d4c82ebef970822198cf0714de830cff4111534ff1@18.223.198.165:31004,enode://24e1c654a801975a96b7f54ebd7452ab15777fc635c1db25bdbd4425fdb04e7f4768e9e838a87ab724320a765e41631d5d37758c933ad0e8668693558125c8aa@18.223.198.165:31000,enode://27010891d960f73d272a553f72b6336c6698db3ade98d631f09c764e57674a797be5ebc6829ddbb65ab564f439ebc75215d20aa98b6f351d12ea623e7d139ac3@3.132.73.210:31001,enode://228e1b8a4931e46f383e30721dac21fb8fb4e5e1b32c870e13b25478c82db3dc1cd9e7ceb93d302a766466b55638cc9c5cbfc43aa48fa41ced19baf365951f76@3.1.142.64:31002,enode://c22eb0d40fc3ad5ea710aeddea906567778166bfe18c157955e8c39b23a46c45db18a0fa2ba07f2b64c81178a8c796aec2a29151533920ead06fcdfc6d8d03c6@47.128.192.57:31004,enode://8ce733abe39fd7ae0a278b9893f85c1193c611a3886168690dd843435460f22cc4d61f9e8d0ace7f5905836a665319a31cccdaacdada2acc69972c382ecce7db@3.1.142.64:31003,enode://b7c1b2bed65a855f7a2104aac9a14674dfdf018fdac763415b373b29ce18cdb81d36328ba4e5c9f12629f3a50c3e8f9ee048f22dbdbe93a82813da89c6b81334@51.20.235.126:31004,enode://95270e0550848a72fb141cf27f1c4ea10714edde365b411dc0fa06c81c0f282ce155eb9fa472b6b8bb9ee98395eeaf4c5a7b02a01fe58b37ea98ba152eda4c37@13.50.94.193:31000,enode://72013391755f24f08567b932feeeec4c893c06e0b1fb480890c83bf87fd277ad86a5ab9cb586db9ae9970371a2f8cb0c96f6c9f69045abca0fb801db7f047138@51.20.235.126:31001" \
      --http \
      --http.addr=0.0.0.0 \
      --http.corsdomain=* \
      --http.vhosts=* \
      --http.port=8659 \
      --authrpc.jwtsecret=/data/jwtsecret.hex \
      --authrpc.addr=0.0.0.0 \
      --authrpc.vhosts=* \
      --authrpc.port=8551 \
      --maxpeers=200 \
      --cache=8000 \
      --port=30314 \
      --discovery.port=30314 \
      --discv4=true \
      --discv5=true \
      --nat=extip:"$PUBLIC_IP" \
      --txpool.nolocals=true \
      --txpool.accountqueue=50000 \
      --txpool.globalqueue=50000 \
      --txpool.globalslots=50000 \
      --txpool.pricelimit=1000000 \
      --txpool.pricebump=1 \
      --rpc.allow-unprotected-txs
    ;;

  *)
    echo "ERROR: CA_NETWORK is not correct, current value: ${CA_NETWORK}"
    exit 1
    ;;

esac
