#!/bin/sh

echo "Retry with sudo if file permission denied."

docker-compose down --volumes --remove-orphans


rm -rf ./artifacts
rm -rf ./configs/crypto
rm -rf ./configs/ledger

echo "Artifacts removed"
echo "You must setup the environment again"
