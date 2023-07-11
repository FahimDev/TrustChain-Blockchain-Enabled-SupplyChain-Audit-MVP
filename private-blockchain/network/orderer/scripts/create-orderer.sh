#!/bin/sh

# Generate the crypto material using cryptogen
# cryptogen generate --config=./configs/crypto-config.yaml --output=./artifacts/crypto-config

echo "===================== Creating Ordererer ===================== "
configtxgen -configPath ./../config -printOrg OrdererOrg > ./artifacts/OrdererOrg.json
