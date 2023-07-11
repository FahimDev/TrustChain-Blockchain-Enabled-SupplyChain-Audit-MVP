#!/bin/bash

# source ../root_config.sh

function docker_orderer_yaml {
    sed -e "s/\${NETWORK_NAME}/$1/g" \
        -e "s/\${ORDERER_NAME}/$2/g" \
        -e "s/\${ORDERER_MSP_ID}/$3/g" \
        -e "s/\${ORDERER_LISTEN_PORT}/$4/g" \
        -e "s/\${ORDERER_OPERATION_LISTEN_PORT}/$5/g" \
        -e "s/\${DOMAIN_ADDRESS}/$6/g" \
        docker/docker-compose-orderer.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function orderer_conftx_yaml {
    sed -e "s/\${ORDERER_CONFIG_NAME}/$1/g" \
        -e "s/\${ORDERER_NAME}/$2/g" \
        -e "s/\${ORDERER_MSP_ID}/$3/g" \
        -e "s/\${ORDERER_LISTEN_PORT}/$4/g" \
        -e "s/\${DOMAIN_ADDRESS}/$5/g" \
        ordererConfigtx-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function generate_docker {
    _NETWORK_NAME=$1
    _ORDERER_NAME=$2
    _ORDERER_MSP_ID=$3
    _ORDERER_LISTEN_PORT=$4
    _ORDERER_OPERATION_LISTEN_PORT=$5
    _DOMAIN_ADDRESS=$6
    echo "$(docker_orderer_yaml $_NETWORK_NAME $_ORDERER_NAME $_ORDERER_MSP_ID $_ORDERER_LISTEN_PORT $_ORDERER_OPERATION_LISTEN_PORT $_DOMAIN_ADDRESS)" > ../organizations/ordererOrganizations/docker-compose-${_ORDERER_NAME}.yaml
}
# echo "$(orderer_conftx_yaml $ORDERER_CONFIG_NAME $ORDERER_NAME $ORDERER_MSP_ID $ORDERER_LISTEN_PORT $DOMAIN_ADDRESS)" > ../organizations/ordererOrganizations/configtx/configtx.yaml
# This operation is handled from _dynamic-config 