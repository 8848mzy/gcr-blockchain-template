#!/bin/bash

# This file runs all the other scripts that are needed to generate the necessary artifacts in order to run a hyperledger network

if [ "$#" -ne 7 ]; then
    echo "Illegal number of parameters. I require 6:"
    echo "\tARG1: DOMAIN_NAME"
    echo "\tARG2: ORG_NAME_1"
    echo "\tARG3: ORG_NAME_2"
    echo "\tARG4: ORG_NAME_3"
    echo "\tARG5: CHANNEL_NAME"
    echo "\tARG6: FABRIC_PATH"
    echo "\tARG7: REPO_URL"
    exit 1
fi

echo "#############################################################"
echo "######  Preparing STAND-ALONE Fabric Network Artifacts ######"
echo "#############################################################"

DOMAIN_NAME=$1
ORG_NAME_1=$2
ORG_NAME_2=$3
ORG_NAME_3=$4
CHANNEL_NAME=$5
FABRIC_PATH=$6
REPO_URL=$7
IP_ADDRESS=`ifconfig | grep -A 1 eth0 | grep "inet addr:" | sed 's/inet addr:\(.*\) Bcast.*/\1/g'| sed 's/ //g'`

echo "Detected IP Address as $IP_ADDRESS"

export GOPATH=/home/ec2-user/hyperledger-fabric
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/bin:/usr/local/bin:$FABRIC_PATH/../platform-specific-binaries/bin
export FABRIC_CFG_PATH=$FABRIC_PATH

env
# Generate config files as specified by the user. This will be input to generate
# private keys and certificates.
./generate_config_files.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3

if [ $? -ne "0" ]; then
  echo "Failed to generate config files. Failing.. "
  exit 1
fi

# Generate Private Keys and Certs for each of the tasks
./generate_certs.sh

if [ "$?" -ne "0" ]; then
  echo "Failed to generate certificates. Failing.. "
  exit 1
fi

#Generate Channel artifacts like the genesis block
./generate_channel_artifacts.sh $CHANNEL_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3

if [ "$?" -ne "0" ]; then
  echo "Failed to generate channel artifacts. Failing.. "
  exit 1
fi


set -x
./detemplatize.sh docker-compose/docker-compose-cli.yaml $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh docker-compose/docker-compose-explorer.yaml $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh docker-compose/docker-compose-base.yaml $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh network-management-scripts/network.sh  $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh network-management-scripts/network-configure.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh network-management-scripts/network-synthetic-transaction.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh network-management-scripts/network-helpers.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh network-management-scripts/network-gen-transaction.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh network-management-scripts/network-gen-transaction-helper.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

./detemplatize.sh explorer-config.json $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $IP_ADDRESS $REPO_URL

set +x


if [ -d "/etc/fabric/" ]; then
  sudo rm -rf /etc/fabric/
fi

sudo mkdir /etc/fabric/
sudo mv ./crypto-config ./channel-artifacts /etc/fabric/
sudo cp -r ./explorer-config.json ./scripts ./chaincode ./tools-config/ ./tools-bin ./network-management-scripts /etc/fabric/

find /etc/fabric/ -exec sudo chmod +r {} \;



echo "#############################################################"
echo "######  Finished! STAND-ALONE Fabric Network Artifacts ######"
echo "#############################################################"

