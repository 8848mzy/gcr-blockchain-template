#!/bin/bash


AWS_REGION=$1
DOMAIN_NAME=$2
ORG_NAME_1=$3
ORG_NAME_2=$4
ORG_NAME_3=$5
CHANNEL_NAME=$6
REPO_URL=$7
REPO_ACCOUNT_ID=$8

#
# Hyperledger Fabric - First Run (Standalone)
#

cd /home/ec2-user/HyperLedger-BasicNetwork/artifacts
chmod +x hyperledger_fabric_prerequisites.sh
./hyperledger_fabric_prerequisites.sh $AWS_REGION ${REPO_URL} $REPO_ACCOUNT_ID

sudo -i -u ec2-user bash -c "cd /home/ec2-user/HyperLedger-BasicNetwork/artifacts ; ./prepare_fabric_artifacts_standalone.sh $DOMAIN_NAME $ORG_NAME_1 $ORG_NAME_2 $ORG_NAME_3 $CHANNEL_NAME /home/ec2-user/HyperLedger-BasicNetwork/artifacts $REPO_URL"

if [ "$?" -ne "0" ]; then
  echo "Failed to prepare artifacts. Failing.. "
  exit 1
fi

sudo -i -u ec2-user bash -c "cd /home/ec2-user/HyperLedger-BasicNetwork/artifacts ; ./network-management-scripts/network.sh up-silent"

if [ "$?" -ne "0" ]; then
  echo "Failed to bring up network. Failing.. "
  exit 1
fi

DOCKER_BRIDGE_INTERFACE=`ifconfig | egrep "^br-" | sed 's/br\-\(.*\) Link.*/br\-\1/'`

set -x
sudo iptables -t nat -A POSTROUTING -o $DOCKER_BRIDGE_INTERFACE -j MASQUERADE

#172.18.0.7 is the IP of the explorer container - note that if we change the startup order this may change
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 172.18.0.7:8080
set +x

echo "Your network should now be up and running, connect to http://localhost:8080 or http://<ec2-host-dns-name>:80 to view the blockchain explorer."
