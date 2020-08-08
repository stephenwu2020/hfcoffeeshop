#!/bin/bash

MODE=$1
CRYPTOGEN=../bin/cryptogen
CONFIGTXGEN=../bin/configtxgen
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/msp/tlscacerts/tlsca.coffeeshop.com-cert.pem

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - crypto"
  echo "  - genesis"
  echo "  - up"
  echo "  - createChanTx"
  echo "  - createChan"
  echo "  - down"
  echo "  - clear"
  echo "  - customs"
}

case "$MODE" in
  "crypto")
    ${CRYPTOGEN} generate --config=./crypto-config.yaml --output="organizations"
    ;;
  "genesis")
    ${CONFIGTXGEN} -profile Genesis -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
    ;;
  "createChanTx")
    ${CONFIGTXGEN} -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    ;;
  "createChan")
    docker exec cli peer channel create \
    -o orderer.coffeeshop.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block \
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
    docker-compose down
    rm -rf organizations system-genesis-block channel-artifacts
    ;;
   "custom")
    ./network.sh clear
    ./network.sh crypto
    ./network.sh genesis
    ./network.sh up 
    ./network.sh createChanTx 
    ./network.sh createChan
    ;;
  *)
    help
    exit 1
esac