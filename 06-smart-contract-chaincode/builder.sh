#!/bin/bash

MODE=$1
CHANNEL_NAME="c1"
TAG="2.0.0"
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
elif [ "$MODE" == "start" ]; then
  execNetwork start
  echo "sleep 5 second ..."
  sleep 5
  execChannel start
  echo "sleep 5 second ..."
  sleep 5
  execChaincode start
elif [ "$MODE" == "end" ]; then
  execNetwork down
  execNetwork clear
else        
  help
  exit 1
fi
