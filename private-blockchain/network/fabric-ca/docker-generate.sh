#!/bin/bash

source ../root_config.sh

function docker_ca_org_yaml {
    sed -e "s/\${NETWORK_NAME}/$1/g" \
        -e "s/\${ORG_NAME}/$2/g" \
        -e "s/\${CA_CORE_PEER_PORT}/$3/g" \
        -e "s/\${CA_LISTEN_PEER_PORT}/$4/g" \
        -e "s/\${CA_USER}/$5/g" \
        -e "s/\${CA_PWD}/$6/g" \
        -e "s/\${DOMAIN_ADDRESS}/$7/g" \
        docker/docker-compose-ca-org.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function docker_ca_orderer_yaml {
    sed -e "s/\${NETWORK_NAME}/$1/g" \
        -e "s/\${ORDERER_NAME}/$2/g" \
        -e "s/\${CA_CORE_ORDERER_PORT}/$3/g" \
        -e "s/\${CA_CORE_ORDERER_LISTEN_PORT}/$4/g" \
        -e "s/\${CA_USER}/$5/g" \
        -e "s/\${CA_PWD}/$6/g" \
        -e "s/\${DOMAIN_ADDRESS}/$7/g" \
        -e "s/\${ORDERER_CA_NAME}/$8/g" \
        docker/docker-compose-ca-orderer.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function generate_docker_orderer {
    echo "$(docker_ca_orderer_yaml $NETWORK_NAME $ORDERER_NAME $CA_CORE_ORDERER_PORT $CA_CORE_ORDERER_LISTEN_PORT $CA_USER $CA_PWD $DOMAIN_ADDRESS $ORDERER_CA_NAME)" > ../organizations/ordererOrganizations/docker-compose-ca-${ORDERER_NAME}.yaml

}

function generate_docker_org {
    _ORG_NAME=$1
    _DOMAIN=$2
    _CA_CORE_PEER_PORT=$3
    _CA_LISTEN_PEER_PORT=$4
    echo "$(docker_ca_org_yaml $NETWORK_NAME $_ORG_NAME $_CA_CORE_PEER_PORT $_CA_LISTEN_PEER_PORT $CA_USER $CA_PWD $_DOMAIN)" > ../organizations/peerOrganizations/docker-compose-ca-${_ORG_NAME}.yaml
}
