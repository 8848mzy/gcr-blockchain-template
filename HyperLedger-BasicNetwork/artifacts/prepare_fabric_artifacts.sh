#!/bin/bash

# This file runs all the other scripts that are needed to generate the necessary artifacts in order to run a hyperledger network

if [ "$#" -ne 9 ]; then
    echo "Illegal number of parameters. Got $# args. I require 9 args that specifies the domain, organization 1, 2 and 3 names, channel name, s3 location, aws region, repo base url, repo account id"
    exit 127
fi

echo "##########################################################"
echo "#########  Preparing Fabric Network Artifacts ############"
echo "##########################################################"

DOMAIN_NAME=$1
ORG_NAME_1=$2
ORG_NAME_2=$3
ORG_NAME_3=$4
CHANNEL_NAME=$5
S3_LOCATION=$6
AWS_REGION=$7
REPO_URL=$8
REPO_ACCOUNT_ID=$9

ORDERER_ADDRESS=orderer.$DOMAIN_NAME
PEER1_ADDRESS=peer0.$ORG_NAME_1.$DOMAIN_NAME
PEER2_ADDRESS=peer0.$ORG_NAME_2.$DOMAIN_NAME
PEER3_ADDRESS=peer0.$ORG_NAME_3.$DOMAIN_NAME
DB_ADDRESS=explorer_db.$DOMAIN_NAME
FABRIC_PATH=/etc/fabric/

IMAGETAG=latest

MY_IP_ADDRESS=`ifconfig | grep -A 1 eth0 | grep "inet addr:" | sed 's/inet addr:\(.*\) Bcast.*/\1/g'| sed 's/ //g'`

export FABRIC_CFG_PATH=${PWD}

echo "Detected IP Address as $MY_IP_ADDRESS"

#detemplatize templates
./detemplatize.sh ./configtx.yaml $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./crypto-config.yaml $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./explorer-config-ecs.json $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./network-management-scripts/network-configure.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./network-management-scripts/network-gen-transaction-helper.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./network-management-scripts/network-helpers.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./network-management-scripts/network-synthetic-transaction.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL
./detemplatize.sh ./docker-compose/docker-compose-cli-only.yaml $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME $FABRIC_PATH $ORDERER_ADDRESS $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $DB_ADDRESS $REPO_URL

if [ $? -ne "0" ]; then
  echo "Failed to generate config files. Failing.. "
  exit 1
fi

cp configtx.yaml tools-config/configtx.yaml
cp crypto-config.yaml tools-config/crypto-config.yaml

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

if [ -d "/etc/fabric/" ]; then
  sudo rm -rf /etc/fabric/
fi

sudo mkdir /etc/fabric/
sudo mv ./crypto-config ./channel-artifacts ./tools-config/ /etc/fabric/
sudo mv ./explorer-config-ecs.json /etc/fabric/explorer-config.json

COUNTER=1
MAX_RETRIES=5

uploadToS3WithRetry () {
  set -x
  aws s3 cp --recursive /etc/fabric/ $S3_LOCATION  2>&log.txt
  res=$?
  set +x
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=` expr $COUNTER + 1`
    echo "Failed to upload artifacts to S3. Retrying. "
    sleep 5
    uploadToS3WithRetry
  else
    COUNTER=1
  fi

  if [ $res -ne 0 ] ; then
    echo "!!!!!!!!!!!!!!! Failed to upload artifacts to S3 !!!!!!!!!!!!!!!!"
    echo
    exit 1
  fi
}


uploadToS3WithRetry

sudo mv ./scripts ./chaincode ./tools-bin ./network-management-scripts ./docker-compose/ /etc/fabric/

find /etc/fabric/ -exec sudo chmod +r {} \;

echo "##########################################################"
echo "#########  Installing Dependencies            ############"
echo "##########################################################"

yum -y install docker
yum -y install epel-release
yum -y install -y python-pip
/usr/bin/pip install docker-compose
/usr/bin/pip install --upgrade pip
yum -y install go

echo "##########################################################"
echo "#########  Starting Docker                    ############"
echo "##########################################################"
sudo service docker start

if [ "$?" -ne "0" ]; then
  echo "Failed to start docker. "
  exit 1
fi

curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
yum -y install -y gcc-c++ make
yum -y install -y nodejs
/usr/bin/npm install npm@5.6.0 -g

usermod -a -G docker ec2-user

set -x
eval `aws ecr get-login --no-include-email --region $AWS_REGION --registry-ids ${REPO_ACCOUNT_ID}`
docker pull ${REPO_URL}fabric-tools:latest

if [ "$?" -ne "0" ]; then
  echo "Failed to pull image from ECR. "
  exit 1
fi

#Start CLI tools for later
IMAGE_TAG=$IMAGETAG /usr/local/bin/docker-compose -f /etc/fabric/docker-compose/docker-compose-cli-only.yaml up -d

if [ "$?" -ne "0" ]; then
  echo "Failed to start Fabric CLI."
  exit 1
fi

cd /home/ec2-user/
rm -rf HyperLedger-BasicNetwork

ln -s /etc/fabric/tools-bin/ /home/ec2-user/
ln -s /etc/fabric/tools-config/ /home/ec2-user/
ln -s /etc/fabric/channel-artifacts/ /home/ec2-user/
ln -s /etc/fabric/chaincode/ /home/ec2-user/

echo "PATH=$PATH:$HOME/tools-bin/" >> /home/ec2-user/.bash_profile
echo "export PATH" >> /home/ec2-user/.bash_profile
echo "export FABRIC_CFG_PATH=/etc/fabric/tools-config/" >> /home/ec2-user/.bash_profile

#Wait till components are ready and then initialize the network.
nohup /etc/fabric/network-management-scripts/ecs_submit_initial_transactions.sh $PEER1_ADDRESS $PEER2_ADDRESS $PEER3_ADDRESS $ORDERER_ADDRESS $DB_ADDRESS $CHANNEL_NAME &

echo "##########################################################"
echo "#########  Finished! Fabric Network Artifacts ############"
echo "##########################################################"
