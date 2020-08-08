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
  echo "  - down"
  echo "  - clear"
  echo "  - custom"
}

function genCrypto(){
  ${CRYPTOGEN} generate --config=./crypto-config.yaml --output="organizations"
}

function genGenesis(){
  ${CONFIGTXGEN} -profile Genesis -channelID ordererchannel -outputBlock ./system-genesis-block/genesis.block
}

function createChanTx(){
  ${CONFIGTXGEN} -profile CC1 -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
  ${CONFIGTXGEN} -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/MingAnchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg Ming
}

function up(){
  docker-compose up -d
}

function down(){
  docker-compose down
}

function clear(){
  down
  rm -rf organizations system-genesis-block channel-artifacts
}

case "$MODE" in
  "crypto")
    genCrypto
    ;;
  "genesis")
    genGenesis
    ;;
  "createChanTx")
    createChanTx
    ;;
  "up")
    up
    ;;
  "down")
    down
    ;;
  "clear")
    clear
    ;;
   "custom")
    clear
    genCrypto
    genGenesis
    createChanTx
    up
    ;;
  *)
    help
    exit 1
esac
