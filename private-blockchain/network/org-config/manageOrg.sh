#!/bin/bash

# Copyright Brain Station 23 Ltd.. All Rights Reserved.
# Md. Ariful Islam [BS1121]
#
# sudo chmod -R 777 inventory-23
# chmod -R 0755 ./configtx
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../organizations/ordererOrganizations/configtx

source ../root_config.sh
. ../scripts/utils.sh

TYPE="organization"
ORG_IMAGETAG="latest"
MODE="up" # Default

# export NETWORK_NAME=NETWORK_NAME
# export PEER_COUNT=PEER_COUNT
# export ORG_NAME=ORG_NAME
# export ORG_NUMBER=ORG_NUMBER
# export DOMAIN_ADDRESS=DOMAIN_ADDRESS
# export CORE_PEER_PORT=CORE_PEER_PORT
# export CORE_PEER_CHAINCODE_LISTEN_PORT=CORE_PEER_CHAINCODE_LISTEN_PORT
# export ORGANIZATION_NAME=ORGANIZATION_NAME
# export LISTEN_PEER_PORT=LISTEN_PEER_PORT
# export DB_NAME=DB_NAME
# export DB_USER=DB_USER
# export DB_PWD=DB_PWD
# export DB_PORT=DB_PORT

function main {
    echo "Current Mode is $MODE"

    if [ "$MODE" == "generate" ]; then
        generate
    elif [ "$MODE" == "up" ]; then
        up
    else
        down
    fi
}

function generate {
    titleln "Generation Type $TYPE"
    which configtxgen
    if [ "$?" -ne 0 ]; then
        echo "configtxgen tool not found. exiting"
    fi

    checkDirectory
    for i in "${!ORGS[@]}"; do
        titleln "Generating CCP files for ${ORGS[$i]}"
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        . ccp-generate.sh
        generate_common_connection_profile ${ORGS[$i]} ${_ORG_NAME_LC} ${PEER_COUNT} ${ORG_DOMAINS[$i]} ${CORE_PEER_PORTS[$i]} ${CA_CORE_PEER_PORT[$i]}
        generate_docker ${NETWORK_NAME} ${ORGS[$i]} ${_ORG_NAME_LC} ${ORG_DOMAINS[$i]} ${PEER_COUNT} ${CORE_PEER_PORTS[$i]} ${LISTEN_PEER_PORTS[$i]} ${CORE_PEER_CHAINCODE_LISTEN_PORTS[$i]} ${DB_PORTS[$i]} ${DB_NAME} ${DB_USER} ${DB_PWD} ${DB_EXTERNAL_PORT}
        sleep 10
        generateOrgDefinition ${ORGS[$i]} ${_ORG_NAME_LC} ${ORG_DOMAINS[$i]} 
        sleep 10
    done
}

function up {
    titleln "#############--------BRINGING UP THE ORGANIZATIONS--------#############"
    for i in "${!ORGS[@]}"; do
        titleln "Docker Image up for Org: ${ORGS[$i]}"
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        PEER_COMPOSE_FILE=../organizations/peerOrganizations/docker-compose-${_ORG_NAME_LC}-${ORG_DOMAINS[$i]}.yaml
        COUCHDB_COMPOSE_FILE=../organizations/peerOrganizations/docker-compose-${DB_NAME}${PEER_COUNT}-${_ORG_NAME_LC}-${ORG_DOMAINS[$i]}.yaml
        IMAGE_TAG=${ORG_IMAGETAG} docker-compose -f $PEER_COMPOSE_FILE -f $COUCHDB_COMPOSE_FILE up -d 2>&1
    done
}

function down {
    titleln "#############--------BRINGING DOWN THE ORGANIZATIONS--------#############"
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        PEER_COMPOSE_FILE=../organizations/peerOrganizations/docker-compose-${_ORG_NAME_LC}-${ORG_DOMAINS[$i]}.yaml
        COUCHDB_COMPOSE_FILE=../organizations/peerOrganizations/docker-compose-${DB_NAME}${PEER_COUNT}-${_ORG_NAME_LC}-${ORG_DOMAINS[$i]}.yaml
        docker-compose -f $PEER_COMPOSE_FILE -f $COUCHDB_COMPOSE_FILE down --volumes --remove-orphans
    done
}

function checkDirectory() {
    # generate artifacts if they don't exist
    if [ ! -d "../organizations/peerOrganizations" ]; then
        echo "Please start your CA server"
        exit 0
    fi
}

# Defining Orgnization Specification
function generateOrgDefinition() {
    _ORG_NAME_CC=$1
    _ORG_NAME_LC=$2
    _DOMAIN=$3
    titleln "Generating organization definition"
    set -x
    configtxgen -printOrg ${_ORG_NAME_CC}MSP > ../organizations/peerOrganizations/${_ORG_NAME_LC}.${_DOMAIN}/${_ORG_NAME_LC}.json
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
        echo "Failed to generate organization definition..."
    fi
}

if [ $# -eq 0 ]; then
    echo "Please Insert Mode (up or down)"
else
    MODE=$1
    main
fi