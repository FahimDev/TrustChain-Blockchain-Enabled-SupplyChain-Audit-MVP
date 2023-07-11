#!/bin/bash

source ../root_config.sh

TYPE="orderer"
COMPOSE_FILE_CA_ORDERER=../organizations/ordererOrganizations/docker-compose-ca-${ORDERER_NAME}.yaml
COMPOSE_FILE_CA_ORG=../organizations/peerOrganizations/docker-compose-ca-${ORG_NAME}${ORG_NUMBER}.yaml
CA_IMAGETAG="latest"
MODE="up"

. ../scripts/utils.sh

export PATH=${PWD}/../bin:${PWD}:$PATH

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
    . docker-generate.sh

    titleln "Generating docker YAML file for Orderer and Organization"
    mkdir -p ../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp
    generate_docker_orderer
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        titleln "Generating docker YAML file for Organization: ${ORGS[$i]}"
        mkdir -p ../organizations/peerOrganizations/${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/ca-temp
        generate_docker_org ${_ORG_NAME_LC} ${ORG_DOMAINS[$i]} ${CA_CORE_PEER_PORT[$i]} ${CA_LISTEN_PEER_PORTS[$i]}
    done
}

function up {
    . scripts/registerEnroll.sh

    titleln "Generating certificates using Fabric CA"
    titleln "Generation CA Type $TYPE"
    if [ "$TYPE" == "orderer" ]; then
        titleln "Docker Image up for Orderer"
        IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA_ORDERER up -d 2>&1
        
        sleep 10
        createOrdererCA
    else
        for i in "${!ORGS[@]}"; do
            titleln "Docker Image up for Org: ${ORGS[$i]}"
            _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
            COMPOSE_FILE_CA_ORG=../organizations/peerOrganizations/docker-compose-ca-${_ORG_NAME_LC}.yaml
            IMAGE_TAG=${CA_IMAGETAG} docker-compose -f $COMPOSE_FILE_CA_ORG up -d 2>&1
            
            sleep 10
            createOrgCA ${_ORG_NAME_LC} ${ORG_DOMAINS[$i]} ${CA_CORE_PEER_PORT[$i]}
        done
    fi
}

function down {
    titleln "Stopping Docker Containers"
    docker-compose -f $COMPOSE_FILE_CA_ORDERER down --volumes --remove-orphans
    for i in "${!ORGS[@]}"; do
            titleln "Docker Image up for Org: ${ORGS[$i]}"
            _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
            COMPOSE_FILE_CA_ORG=../organizations/peerOrganizations/docker-compose-ca-${_ORG_NAME_LC}.yaml

            docker-compose -f $COMPOSE_FILE_CA_ORG down --volumes --remove-orphans
    done
}

if [ $# -eq 0 ]; then
    errorln "Please Insert Mode (up or down)"
else
    if [ $# -eq 1 ]; then
        MODE=$1
    else
        MODE=$1
        TYPE=$2
    fi

    main
fi