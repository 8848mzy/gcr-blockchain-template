#!/bin/bash

echo
echo "##########################################################"
echo "##### Generate certificates using cryptogen tool #########"
echo "##########################################################"

if [ -d "crypto-config" ]; then
  rm -Rf crypto-config
fi
set -x
./tools-bin/cryptogen generate --config=./crypto-config.yaml
res=$?
set +x
if [ $res -ne 0 ]; then
  echo "Failed to generate certificates..."
  exit 1
fi
echo
