#!/bin/bash

MODE=$1
CRYPTOGEN=../bin/cryptogen
CONFIGTXGEN=../bin/configtxgen
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/demo.com/orderers/o4.demo.com/msp/tlscacerts/tlsca.demo.com-cert.pem

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - channeltx"
  echo "  - channel"
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
  "channeltx")
    ${CONFIGTXGEN} -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    ;;
  "channel")
    docker exec cli peer channel create \
    -o o4.demo.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --tls true \
    --cafile $CAFILE
    ;;
  "up")
    docker-compose up -d
    ;;
  "down")
    docker-compose down
    ;;
  "clear")
    rm -rf organizations system-genesis-block channel-artifacts
    ;;
  *)
    help
    exit 1
esac