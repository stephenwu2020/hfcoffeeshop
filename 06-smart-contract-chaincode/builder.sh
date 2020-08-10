#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD

function help(){
  echo "Usage: "
  echo "  ./builder.sh <cmd>"
  echo "cmd: "
  echo "  - network"
  echo "  - channel"
  echo "  - chaincode"
  echo "  - custom"
  echo "  - clear"
}

function execNetwork(){
  scripts/network.sh $1
}

function execChaincode(){
  docker exec cli scripts/chaincode.sh $1
}

function execChannel(){
  docker exec cli scripts/channel.sh $1
}


case "$MODE" in
  "network")
    execNetwork $2
    ;;
  "channel")
    execChannel $2
    ;;
  "chaincode")
    execChaincode $2
    ;;
  "custom")
    ./builder.sh network custom
    ./builder.sh channel custom
    ./builder.sh chaincode custom
    ;;
  "clear")
    ./builder.sh network clear
    ;;
  *)
    help
    exit 1
esac
