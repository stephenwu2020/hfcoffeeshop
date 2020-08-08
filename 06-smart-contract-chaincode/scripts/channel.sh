#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/msp/tlscacerts/tlsca.coffeeshop.com-cert.pem

# r1 env
R1MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/users/Admin@ming.coffeeshop.com/msp
R1ADDR=peer0.ming.coffeeshop.com:7051
R1MSPID="MingMSP"
R1CRT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/ca.crt 

function help(){
  echo "Usage: "
  echo "  channel.sh <cmd>"
  echo "cmd: "
  echo "  - create"
  echo "  - join"
  echo "  - anchor"
  echo "  - info"
  echo "  - custom"
}

function createChan(){
  peer channel create \
    -o orderer.coffeeshop.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx \
    --outputBlock /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block \
    --tls \
    --cafile $CAFILE
}

function joinChan(){
  # r1 join
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  peer channel join \
    -b /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.block

}

function showChanInfo(){
  peer channel list
  peer channel getinfo -c ${CHANNEL_NAME}
}

function setAnchor(){
 
  # anchor update
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  peer channel update \
    -o orderer.coffeeshop.com:7050 \
    -c $CHANNEL_NAME \
    -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/MingAnchors.tx \
    --tls \
    --cafile $CAFILE

  # show info
  showChanInfo
}

if [ "$MODE" == "create" ]; then
  createChan    
elif [ "$MODE" == "join" ]; then
  joinChan
elif [ "$MODE" == "anchor" ]; then
  setAnchor
elif [ "$MODE" == "info" ]; then
  showChanInfo
elif [ "$MODE" == "custom" ]; then
  createChan
  sleep 5
  joinChan
  sleep 5
  setAnchor
  sleep 5
  showChanInfo
else        
  help
  exit 1
fi
