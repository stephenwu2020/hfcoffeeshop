#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
CHAINCODE_NAME="mycc"
CAFILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/coffeeshop.com/orderers/orderer.coffeeshop.com/msp/tlscacerts/tlsca.coffeeshop.com-cert.pem

# r1 env
R1MSP=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/users/Admin@ming.coffeeshop.com/msp
R1ADDR=peer0.ming.coffeeshop.com:7051
R1MSPID="MingMSP"
R1CRT=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/ca.crt 

function help(){
  echo "Usage: "
  echo "  chaincode.sh <cmd>"
  echo "cmd: "
  echo "  - package"
  echo "  - install"
  echo "  - approve"
  echo "  - beforeCommit"
  echo "  - commit"
  echo "  - afterCommit"
  echo "  - invoke"
  echo "  - query"
  echo "  - custom"
}

function package(){
  if [ -f "pkg/${CHAINCODE_NAME}.tar.gz" ]; then
    echo "pkg already exist"
  else
    echo "fetch go dependency"
    pushd /opt/gopath/src/github.com/hyperledger/fabric-samples/chaincode/abstore/go
    GO111MODULE=on go mod vendor
    popd

    echo "package chaincode"
    peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz \
      --path github.com/hyperledger/fabric-samples/chaincode/abstore/go/ \
      --lang golang \
      --label abstore_1

    cp ${CHAINCODE_NAME}.tar.gz /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg
  fi
}

function install(){
  GO111MODULE=on

  # install on peer of r1
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  peer lifecycle chaincode install /opt/gopath/src/github.com/hyperledger/fabric/peer/pkg/${CHAINCODE_NAME}.tar.gz

}

function approve(){
  # query
  peer lifecycle chaincode queryinstalled >&log.txt
  cat log.txt
  PACKAGE_ID=`sed -n '/Package/{s/^Package ID: //; s/, Label:.*$//; $p;}' log.txt`
  echo PackageID is ${PACKAGE_ID}

  # approve r1
  CORE_PEER_MSPCONFIGPATH=${R1MSP}
  CORE_PEER_ADDRESS=${R1ADDR}
  CORE_PEER_LOCALMSPID=${R1MSPID}
  CORE_PEER_TLS_ROOTCERT_FILE=${R1CRT}
  peer lifecycle chaincode approveformyorg \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version 1.0 \
    --init-required \
    --package-id $PACKAGE_ID \
    --sequence 1 \
    --tls \
    --cafile $CAFILE
 
}

function beforeCommit(){
  # checkcommitreadiness
  peer lifecycle chaincode checkcommitreadiness \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version 1.0 \
    --sequence 1 \
    --init-required \
    --output json
}

function commit(){
  peer lifecycle chaincode commit \
    -o orderer.coffeeshop.com:7050 \
    --channelID $CHANNEL_NAME \
    --name ${CHAINCODE_NAME} \
    --version 1.0 \
    --sequence 1 \
    --init-required \
    --tls true \
    --cafile $CAFILE \
    --peerAddresses peer0.ming.coffeeshop.com:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/ca.crt 
}

function afterCommit(){
  peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME}
}

function invoke(){
  peer chaincode invoke \
    -o orderer.coffeeshop.com:7050 \
    --isInit \
    --tls \
    --cafile $CAFILE \
    -C $CHANNEL_NAME \
    -n ${CHAINCODE_NAME} \
    --peerAddresses peer0.ming.coffeeshop.com:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/ming.coffeeshop.com/peers/peer0.ming.coffeeshop.com/tls/ca.crt \
    -c '{"Args":["Init","a","100","b","100"]}' \
    --waitForEvent
}

function query(){
  peer chaincode query -C $CHANNEL_NAME -n ${CHAINCODE_NAME} -c '{"Args":["query","a"]}'
}

if [ "$MODE" == "package" ]; then
  package
elif [ "$MODE" == "install" ]; then
  install
elif [ "$MODE" == "approve" ]; then
  approve
elif [ "$MODE" == "beforeCommit" ]; then
  beforeCommit
elif [ "$MODE" == "commit" ]; then
  commit
elif [ "$MODE" == "afterCommit" ]; then
  afterCommit
elif [ "$MODE" == "invoke" ]; then
  invoke
elif [ "$MODE" == "debug" ]; then
  debug
elif [ "$MODE" == "query" ]; then
  query
elif [ "$MODE" == "custom" ]; then
  package
  install
  approve
  beforeCommit
  commit
  afterCommit
  invoke
  query
else        
  help
  exit 1
fi
