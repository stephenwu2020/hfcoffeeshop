#!/bin/bash

MODE=$1
CRYPTOGEN=../bin/cryptogen
CONFIGTXGEN=../bin/configtxgen

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - up"
  echo "  - down"
  echo "  - clear"
}

case "$MODE" in
  "crypto")
    ${CRYPTOGEN} generate --config=./crypto-config.yaml --output="organizations"
    ;;
  "genesis")
    ${CONFIGTXGEN} -profile NC4 -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
    ;;
  "up")
    docker-compose up -d
    ;;
  "down")
    docker-compose down
    ;;
  "clear")
    rm -rf organizations system-genesis-block
    ;;
  *)
    help
    exit 1
esac