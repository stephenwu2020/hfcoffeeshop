#!/bin/bash

MODE=$1
CRYPTOGEN=../bin/cryptogen
CONFIGTXGEN=../bin/configtxgen
CHANNEL_NAME="c1"
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
  echo "  - joinChan"
  echo "  - setAnchor"
  echo "  - listChan"
  echo "  - down"
  echo "  - clear"
  echo "  - custom"
}

function joinChan(){
  # join
  docker exec \
    cli peer channel join \
    -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block
  # show info
  listChan
}

function listChan(){
  docker exec cli peer channel list
  docker exec cli peer channel getinfo -c ${CHANNEL_NAME}
}

function setAnchor(){
  # anchor tx
  ${CONFIGTXGEN} -profile CC1 \
    -outputAnchorPeersUpdate ./channel-artifacts/MingAnchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg Ming
  # anchor update
  docker exec \
    cli peer channel update \
    -o orderer.coffeeshop.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/MingAnchors.tx \
    --tls \
    --cafile $CAFILE
  # show info
  listChan
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
  "joinChan")
    joinChan
    ;; 
  "setAnchor") 
    setAnchor
    ;;
  "listChan")
    listChan
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
    sleep 5
    ./network.sh createChanTx 
    sleep 5
    ./network.sh createChan
    sleep 5
    ./network.sh joinChan
    sleep 5
    ./network.sh setAnchor
    ./network.sh listChan 
    ;;
  *)
    help
    exit 1
esac
