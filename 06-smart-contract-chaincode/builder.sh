#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
FABRIC_CFG_PATH=$PWD

function help(){
  echo "Usage: "
  echo "  network.sh <cmd>"
  echo "cmd: "
  echo "  - start"
  echo "  - end"
  echo "  - network"
  echo "  - channel"
  echo "  - chaincode"
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


if [ "$MODE" == "network" ]; then
  execNetwork $2
elif [ "$MODE" == "channel" ]; then
  execChannel $2
elif [ "$MODE" == "chaincode" ]; then
  execChaincode $2
else        
  help
  exit 1
fi
