#!/bin/bash
#
# This script will wait till the entire network is up and running and then initialize the network.
# This is done by waiting till the Route53 entries for each component is changed from the default localhost.
#

ORG1_PEER_ADDR=$1
ORG2_PEER_ADDR=$2
ORG3_PEER_ADDR=$3
ORDERER_PEER_ADDR=$4
EXLORER_PEER_ADDR=$5
CHANNEL_NAME=$6

for addr in $ORG1_PEER_ADDR $ORG2_PEER_ADDR $ORG3_PEER_ADDR $ORDERER_PEER_ADDR $EXLORER_PEER_ADDR
do
    found=false
    while [ "$found" == "false" ]; do
        rc=`host $addr`
        if [ $? -ne 0 ]; then
            echo "Address $addr has no route 53 record yet"
            sleep 10
        else
            rc=`host $addr | grep -v "127.0.0.1"`
            if [ "$rc" != "" ] && [ "$rc" != "not found" ]; then
                    echo "Address $addr is now available"
                    found=true
            else
                    echo "Address $addr is not available. Ip is still default."
                    sleep 10
            fi
        fi
    done
done

docker exec cli /opt/gopath/src/github.com/hyperledger/fabric/network-management-scripts/network-configure.sh