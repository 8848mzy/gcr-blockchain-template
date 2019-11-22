#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters. I require 4 args that specifies the domain, organization 1, 2 and 3 names"
    exit 1
fi

DOMAIN_NAME=$1
ORG_NAME_1=$2
LC_ORG_NAME_1=`echo "$ORG_NAME_1" | tr '[:upper:]' '[:lower:]'`
ORG_NAME_2=$3
LC_ORG_NAME_2=`echo "$ORG_NAME_2" | tr '[:upper:]' '[:lower:]'`
ORG_NAME_3=$4
LC_ORG_NAME_3=`echo "$ORG_NAME_3" | tr '[:upper:]' '[:lower:]'`

ARCH=`uname -s | grep Darwin`
if [ "$ARCH" == "Darwin" ]; then
OPTS="-it"
else
OPTS="-i"
fi

cp configtx.yaml.template configtx.yaml
sed $OPTS "s/\%ORG_NAME_1\%/$ORG_NAME_1/g" configtx.yaml
sed $OPTS "s/\%LC_ORG_NAME_1\%/$LC_ORG_NAME_1/g" configtx.yaml
sed $OPTS "s/\%ORG_NAME_2\%/$ORG_NAME_2/g" configtx.yaml
sed $OPTS "s/\%LC_ORG_NAME_2\%/$LC_ORG_NAME_2/g" configtx.yaml
sed $OPTS "s/\%ORG_NAME_3\%/$ORG_NAME_3/g" configtx.yaml
sed $OPTS "s/\%LC_ORG_NAME_3\%/$LC_ORG_NAME_3/g" configtx.yaml
sed $OPTS "s/\%DOMAIN_NAME\%/$DOMAIN_NAME/g" configtx.yaml

cp crypto-config.yaml.template crypto-config.yaml
sed $OPTS "s/\%ORG_NAME_1\%/$ORG_NAME_1/g" crypto-config.yaml
sed $OPTS "s/\%LC_ORG_NAME_1\%/$LC_ORG_NAME_1/g" crypto-config.yaml
sed $OPTS "s/\%ORG_NAME_2\%/$ORG_NAME_2/g" crypto-config.yaml
sed $OPTS "s/\%LC_ORG_NAME_2\%/$LC_ORG_NAME_2/g" crypto-config.yaml
sed $OPTS "s/\%ORG_NAME_3\%/$ORG_NAME_3/g" crypto-config.yaml
sed $OPTS "s/\%LC_ORG_NAME_3\%/$LC_ORG_NAME_3/g" crypto-config.yaml
sed $OPTS "s/\%DOMAIN_NAME\%/$DOMAIN_NAME/g" crypto-config.yaml
