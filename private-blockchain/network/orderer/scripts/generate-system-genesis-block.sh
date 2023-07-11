#!/bin/sh

# Generate the crypto material using cryptogen

echo "===================== Generate System Genesis Block ===================== "

configtxgen -configPath ./../config -profile OrdererGenesis -channelID system-channel -outputBlock ./../system-genesis-block/genesis.block