#!/bin/bash

# This script is currently capable of 
# creating CA server, MSP services & 
# declearing Organization definations.
# After a successful executrion there 
# will be three containers running at docker 
# 

cd fabric-ca 

./manageCA.sh up org
./manageCA.sh up orderer

cd ..

cd org-config 

./manageOrg.sh up

cd ..

# cd orderer

# ./scripts/setup-env.sh
# ./scripts/create-orderer.sh
# ./scripts/start-orderer.sh

# cd ..

echo "Welcome to root."
