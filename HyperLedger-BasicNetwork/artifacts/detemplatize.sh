#!/bin/bash

if [ "$#" -ne 13 ]; then
    echo "Illegal number of parameters. I require 12:"
    echo "\tARG1: TEMPLATE_FILE (for example: docker-compose-cli.yaml   - lease off the .template)"
    echo "\tARG2: DOMAIN_NAME"
    echo "\tARG3: ORG_NAME_1"
    echo "\tARG4: ORG_NAME_2"
    echo "\tARG5: ORG_NAME_3"
    echo "\tARG6: CHANNEL_NAME"
    echo "\tARG7: FABRIC_PATH"
    echo "\tARG8: ORDER_ADDRESS"
    echo "\tARG9: PEER0_ORG1_ADDRESS"
    echo "\tARG10: PEER0_ORG2_ADDRESS"
    echo "\tARG11: PEER0_ORG3_ADDRESS"
    echo "\tARG12: EXPLORER_DB_ADDRESS"
    echo "\tARG13: REPO_URL"
    exit 1
fi

#
# Available template substitutions
#
#%ORG_NAME_1%
#%LC_ORG_NAME_1%
#%ORG_NAME_2%
#%LC_ORG_NAME_2%
#%ORG_NAME_3%
#%LC_ORG_NAME_3%
#%DOMAIN_NAME%
#%CHANNEL_NAME%
#%FABRIC_PATH%
#%FABRIC_CFG_PATH%
#%ORDER_ADDRESS%
#%PEER0_ORG1_ADDRESS%
#%PEER0_ORG2_ADDRESS%
#%PEER0_ORG3_ADDRESS%



TEMPLATE_FILE=$1
DOMAIN_NAME=$2
ORG_NAME_1=$3
LC_ORG_NAME_1=`echo "$ORG_NAME_1" | tr '[:upper:]' '[:lower:]'`
ORG_NAME_2=$4
LC_ORG_NAME_2=`echo "$ORG_NAME_2" | tr '[:upper:]' '[:lower:]'`
ORG_NAME_3=$5
LC_ORG_NAME_3=`echo "$ORG_NAME_3" | tr '[:upper:]' '[:lower:]'`
CHANNEL_NAME=$6


#This isn't perfect but it handle common items in paths like '/' and '-'
FABRIC_PATH="$(echo $7 | sed 's/\//\\\//g'| sed 's/\-/\\-/g')"

ORDER_ADDRESS=$8
PEER0_ORG1_ADDRESS=$9
PEER0_ORG2_ADDRESS=${10}
PEER0_ORG3_ADDRESS=${11}
EXPLORER_DB_ADDRESS=${12}
REPO_URL="$(echo ${13} | sed 's/\//\\\//g'| sed 's/\-/\\-/g' | sed 's/\./\\./g')"

CFG_PATH="\/etc\/fabric"

ARCH=`uname -s | grep Darwin`
if [ "$ARCH" == "Darwin" ]; then
OPTS="-it"
else
OPTS="-i"
fi

cp $TEMPLATE_FILE.template $TEMPLATE_FILE

echo "sed $OPTS "s/\%ORG_NAME_1\%/$ORG_NAME_1/g" $TEMPLATE_FILE"
sed $OPTS "s/\%ORG_NAME_1\%/$ORG_NAME_1/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%LC_ORG_NAME_1\%/$LC_ORG_NAME_1/g" $TEMPLATE_FILE"
sed $OPTS "s/\%LC_ORG_NAME_1\%/$LC_ORG_NAME_1/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%ORG_NAME_2\%/$ORG_NAME_2/g" $TEMPLATE_FILE"
sed $OPTS "s/\%ORG_NAME_2\%/$ORG_NAME_2/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%LC_ORG_NAME_2\%/$LC_ORG_NAME_2/g" $TEMPLATE_FILE"
sed $OPTS "s/\%LC_ORG_NAME_2\%/$LC_ORG_NAME_2/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%ORG_NAME_3\%/$ORG_NAME_3/g" $TEMPLATE_FILE"
sed $OPTS "s/\%ORG_NAME_3\%/$ORG_NAME_3/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%LC_ORG_NAME_3\%/$LC_ORG_NAME_3/g" $TEMPLATE_FILE"
sed $OPTS "s/\%LC_ORG_NAME_3\%/$LC_ORG_NAME_3/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%DOMAIN_NAME\%/$DOMAIN_NAME/g" $TEMPLATE_FILE"
sed $OPTS "s/\%DOMAIN_NAME\%/$DOMAIN_NAME/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%CHANNEL_NAME\%/$CHANNEL_NAME/g" $TEMPLATE_FILE"
sed $OPTS "s/\%CHANNEL_NAME\%/$CHANNEL_NAME/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%FABRIC_PATH\%/$FABRIC_PATH/g" $TEMPLATE_FILE"
sed $OPTS "s/\%FABRIC_PATH\%/$FABRIC_PATH/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%FABRIC_CFG_PATH\%/$CFG_PATH/g" $TEMPLATE_FILE"
sed $OPTS "s/\%FABRIC_CFG_PATH\%/$CFG_PATH/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%ORDER_ADDRESS\%/$ORDER_ADDRESS/g" $TEMPLATE_FILE"
sed $OPTS "s/\%ORDER_ADDRESS\%/$ORDER_ADDRESS/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%PEER0_ORG1_ADDRESS\%/$PEER0_ORG1_ADDRESS/g" $TEMPLATE_FILE"
sed $OPTS "s/\%PEER0_ORG1_ADDRESS\%/$PEER0_ORG1_ADDRESS/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%PEER0_ORG2_ADDRESS\%/$PEER0_ORG2_ADDRESS/g" $TEMPLATE_FILE"
sed $OPTS "s/\%PEER0_ORG2_ADDRESS\%/$PEER0_ORG2_ADDRESS/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%PEER0_ORG3_ADDRESS\%/$PEER0_ORG3_ADDRESS/g" $TEMPLATE_FILE"
sed $OPTS "s/\%PEER0_ORG3_ADDRESS\%/$PEER0_ORG3_ADDRESS/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%EXPLORER_DB_ADDRESS\%/$EXPLORER_DB_ADDRESS/g" $TEMPLATE_FILE"
sed $OPTS "s/\%EXPLORER_DB_ADDRESS\%/$EXPLORER_DB_ADDRESS/g" $TEMPLATE_FILE

echo "sed $OPTS "s/\%REPO_URL\%/$REPO_URL/g" $TEMPLATE_FILE"
sed $OPTS "s/\%REPO_URL\%/$REPO_URL/g" $TEMPLATE_FILE

