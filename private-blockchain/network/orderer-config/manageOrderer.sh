#!/bin/bash

source ../root_config.sh
. ../scripts/utils.sh

export PATH=${PWD}/../bin:${PWD}:$PATH

MODE="up" # Default

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

    checkDirectory
    createBasicDirectory $ORDERER_NAME $DOMAIN_ADDRESS

    # Generating Docker and Config File
    . generate.sh
    generate_docker $NETWORK_NAME $ORDERER_NAME $ORDERER_MSP_ID $ORDERER_LISTEN_PORT $ORDERER_OPERATION_LISTEN_PORT $DOMAIN_ADDRESS

    # Generate the crypto material using cryptogen
    titleln "===================== Creating Ordererer ===================== "
    configtxgen -configPath ../organizations/ordererOrganizations/configtx -printOrg ${ORDERER_CONFIG_NAME} > ../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/${ORDERER_NAME}-temp/artifacts/${ORDERER_CONFIG_NAME}.json

    # Generate the crypto material using cryptogen
    titleln "===================== Generate System Genesis Block ===================== "
    configtxgen -configPath ../organizations/ordererOrganizations/configtx -profile OrdererGenesis -channelID system-channel -outputBlock ../organizations/system-genesis-block/genesis.block
}


function up {
    checkDirectory
    titleln "===================== Starting Ordererer ===================== "
    IMAGE_TAG=${ORG_IMAGETAG} docker-compose -f ../organizations/ordererOrganizations/docker-compose-${ORDERER_NAME}.yaml up -d 2>&1

}

function down {
    docker-compose -f ../organizations/ordererOrganizations/docker-compose-${ORDERER_NAME}.yaml down --volumes --remove-orphans
    warnln "Artifacts removed"
    warnln "You must setup the environment again"
}

function checkDirectory() {
    # generate artifacts if they don't exist
    if [ ! -d "../organizations/ordererOrganizations" ]; then
        errorln "Please start your CA server"
        exit 0
    fi

    if [ ! -d "../organizations/ordererOrganizations/configtx" ]; then
        errorln "ConfixTx directory location Missing!"
        exit 0
    fi
}

function createBasicDirectory {
    _ORDERER_NAME_LC=$1
    _DOMAIN=$2
    # Create temporary directory for the generated artifacts
    infoln "Creating Basic Directory........."
    mkdir -p ../organizations/ordererOrganizations/${_DOMAIN}/${_ORDERER_NAME_LC}-temp/artifacts
    mkdir -p ../organizations/ordererOrganizations/configtx
    mkdir -p ../organizations/system-genesis-block
}


if [ $# -eq 0 ]; then
    echo "Please Insert Mode (up or down)"
else
    MODE=$1
    main
fi