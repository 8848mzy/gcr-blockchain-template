#!/bin/bash

AWS_REGION=$1
REPO_URL=$2
REPO_ACCOUNT_ID=$3

ORDERER_DOCKER_REPO=${REPO_URL}fabric-orderer:latest
PEER_DOCKER_REPO=${REPO_URL}fabric-peer:latest
TOOLS_DOCKER_REPO=${REPO_URL}fabric-tools:latest
EXPLORER_DOCKER_REPO=${REPO_URL}fabric-explorer:latest
EXPLORER_DB_DOCKER_REPO=${REPO_URL}fabric-explorer-db:latest
BASE_OS_DOCKER_REPO=${REPO_URL}fabric-baseos:latest
CCENV_DOCKER_REPO=${REPO_URL}fabric-ccenv:latest

echo "Preparing to install fabric pre-requisites from $AWS_REGION."
echo "Using Explorer Docker Repo: $EXPLORER_DOCKER_REPO"
echo "Using Explorer DB Docker Repo: $EXPLORER_DB_DOCKER_REPO"

chmod +x ./network-management-scripts/*
chmod +x ./tools-bin/*
chmod +x ./scripts/*
chmod +x *sh
chmod +x ../containers/blockchain-explorer-container/build-containers.sh
chmod +x ../containers/blockchain-explorer-container/blockchain-explorer/*sh

yum -y install docker
yum -y install epel-release
yum -y install -y python-pip
/usr/bin/pip install docker-compose
/usr/bin/pip install --upgrade pip
yum -y install go


#
# ensure docker started
#
sudo service docker start

#
# Get and install nodejs
#
curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
yum -y install -y gcc-c++ make
yum -y install -y nodejs
/usr/bin/npm install npm@5.6.0 -g

sudo -u ec2-user ./nodejs_user_prerequisits.sh

usermod -a -G docker ec2-user

echo "patched-1"

#
# Now grab the samples incase we'd like to experiement with other topologies
#

mkdir /home/ec2-user/hyperledger-fabric-samples
mkdir /home/ec2-user/hyperledger-fabric-samples/go
mkdir /home/ec2-user/hyperledger-fabric-samples/platform-specific-binaries

echo "PATH=$PATH:$HOME/.local/bin:$HOME/bin" >> /home/ec2-user/.bash_profile
echo "export PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/bin:/bin:/usr/local/bin:/home/ec2-user/HyperLedger-BasicNetwork/artifacts/tools-bin" >> /home/ec2-user/.bash_profile
echo "export FABRIC_CFG_PATH=/home/ec2-user/HyperLedger-BasicNetwork/artifacts" >> /home/ec2-user/.bash_profile

echo "alias gen='/home/ec2-user/HyperLedger-BasicNetwork/artifacts/prepare_fabric_artifacts_standalone.sh some.com organ1 organ2 organ3 mychannel /home/ec2-user/HyperLedger-BasicNetwork/artifacts'" >> /home/ec2-user/.bash_profile
echo "alias down='/home/ec2-user/HyperLedger-BasicNetwork/artifacts/network-management-scripts/network.sh down'" >> /home/ec2-user/.bash_profile
echo "alias lsc='docker container list'" >> /home/ec2-user/.bash_profile
echo "alias up='/home/ec2-user/HyperLedger-BasicNetwork/artifacts/network-management-scripts/network.sh up'" >> /home/ec2-user/.bash_profile
echo "alias up-silent='/home/ec2-user/HyperLedger-BasicNetwork/artifacts/network-management-scripts/network.sh up-silent'" >> /home/ec2-user/.bash_profile
echo "alias transaction='/home/ec2-user/HyperLedger-BasicNetwork/artifacts/network-management-scripts/network.sh transaction'" >> /home/ec2-user/.bash_profile

cd /home/ec2-user/hyperledger-fabric-samples

git clone -b master https://github.com/hyperledger/fabric-samples.git
cd fabric-samples
git checkout v1.1.0

#cd ../platform-specific-binaries
#curl -sSL https://goo.gl/6wtTN5 | bash -s 1.1.0

chown -R ec2-user:ec2-user /home/ec2-user/hyperledger-fabric-samples
eval `aws ecr get-login --no-include-email --region $AWS_REGION --registry-ids ${REPO_ACCOUNT_ID}`

#
# Get the Amazon Images
#
set -x
eval `aws ecr get-login --no-include-email --region $AWS_REGION --registry-ids ${REPO_ACCOUNT_ID}`
docker pull $EXPLORER_DB_DOCKER_REPO
docker pull $EXPLORER_DOCKER_REPO
docker pull $ORDERER_DOCKER_REPO
docker pull $TOOLS_DOCKER_REPO
docker pull $PEER_DOCKER_REPO
docker pull $BASE_OS_DOCKER_REPO
docker pull $CCENV_DOCKER_REPO

docker tag `docker image list | grep amazonaws | grep ccenv | awk '{print $3}'` hyperledger/fabric-ccenv:x86_64-1.1.0
docker tag `docker image list | grep amazonaws | grep baseos | awk '{print $3}'` hyperledger/fabric-baseos:x86_64-0.4.6
set +x