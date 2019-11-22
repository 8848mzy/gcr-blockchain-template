#!/bin/bash

if [ "$#" -ne 4 ]; then
  echo "Illegal number of parameters. I require 1 arg that specifies the channel."
  exit 1
fi

CHANNEL_NAME=$1
ORG_NAME_1=$2
ORG_NAME_2=$3
ORG_NAME_3=$4

env
echo "Channel Name we are going to create: $CHANNEL_NAME"

# Create the channel-artifacts directory if it doesn't exist
if [ -d "./channel-artifacts" ]; then
  rm -Rf channel-artifacts
fi

mkdir channel-artifacts

echo "##########################################################"
echo "#########  Generating Orderer Genesis block ##############"
echo "##########################################################"
# Note: For some unknown reason (at least for now) the block file can't be
# named orderer.genesis.block or the orderer will fail to launch!
set -x
./tools-bin/configtxgen -profile ThreeOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi
echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
set -x
./tools-bin/configtxgen -profile ThreeOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for Org1MSP   ##########"
echo "#################################################################"
set -x
./tools-bin/configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORG_NAME_1}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ${ORG_NAME_1}MSP
res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for Org2MSP   ##########"
echo "#################################################################"
set -x
./tools-bin/configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORG_NAME_2}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ${ORG_NAME_2}MSP
res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi
echo

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for Org2MSP   ##########"
echo "#################################################################"
set -x
./tools-bin/configtxgen -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORG_NAME_3}MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ${ORG_NAME_3}MSP
res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi
echo
