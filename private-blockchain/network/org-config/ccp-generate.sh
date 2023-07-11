#!/bin/bash

# source ../root_config.sh

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $7)
    local CP=$(one_line_pem $8)
    sed -e "s/\${ORGANIZATION}/$1/" \
        -e "s/\${ORG}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s/\${PEER_NUMBER}/$5/" \
        -e "s/\${ORG_DOMAIN_ADDRESS}/$6/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $7)
    local CP=$(one_line_pem $8)
    sed -e "s/\${ORGANIZATION}/$1/" \
        -e "s/\${ORG}/$2/" \
        -e "s/\${P0PORT}/$3/" \
        -e "s/\${CAPORT}/$4/" \
        -e "s/\${PEER_NUMBER}/$5/" \
        -e "s/\${ORG_DOMAIN_ADDRESS}/$6/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function generate_common_connection_profile {
    _ORGANIZATION=$1
    _ORG=$2
    _PEER_NUMBER=$3
    _ORG_DOMAIN_ADDRESS=$4
    _P0PORT=$5
    _CAPORT=$6
    PEERPEM=../organizations/peerOrganizations/${_ORG}.${_ORG_DOMAIN_ADDRESS}/tlsca/tlsca.${_ORG}.${_ORG_DOMAIN_ADDRESS}-cert.pem
    CAPEM=../organizations/peerOrganizations/${_ORG}.${_ORG_DOMAIN_ADDRESS}/ca/ca.${_ORG}.${_ORG_DOMAIN_ADDRESS}-cert.pem
    # Common Connection Profile (JSON/YAML)
    echo "$(json_ccp $_ORGANIZATION $_ORG $_P0PORT $_CAPORT $_PEER_NUMBER $_ORG_DOMAIN_ADDRESS $PEERPEM $CAPEM)" > ../organizations/peerOrganizations/${_ORG}.${_ORG_DOMAIN_ADDRESS}/connection-${_ORG}.json
    echo "$(yaml_ccp $_ORGANIZATION $_ORG $_P0PORT $_CAPORT $_PEER_NUMBER $_ORG_DOMAIN_ADDRESS $PEERPEM $CAPEM)" > ../organizations/peerOrganizations/${_ORG}.${_ORG_DOMAIN_ADDRESS}/connection-${_ORG}.yaml
}

function docker_peer_yaml {
    sed -e "s/\${NETWORK_NAME}/$1/g" \
        -e "s/\${ORGANIZATION_NAME}/$2/g" \
        -e "s/\${ORG_NAME}/$3/g" \
        -e "s/\${DOMAIN_ADDRESS}/$4/g" \
        -e "s/\${PEER_COUNT}/$5/g" \
        -e "s/\${CORE_PEER_PORT}/$6/g" \
        -e "s/\${CORE_PEER_CHAINCODE_LISTEN_PORT}/$7/g" \
        -e "s/\${LISTEN_PEER_PORT}/$8/g" \
        docker/docker-compose-org-peer-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

# if 10th peram required use ${10}, ${11} etc .....

function docker_db_yaml {
    sed -e "s/\${NETWORK_NAME}/$1/g" \
        -e "s/\${DB_NAME}/$2/g" \
        -e "s/\${DB_PORT}/$3/g" \
        -e "s/\${DB_USER}/$4/g" \
        -e "s/\${DB_PWD}/$5/g" \
        -e "s/\${PEER_COUNT}/$6/g" \
        -e "s/\${ORG_NAME}/$7/g" \
        -e "s/\${DOMAIN_ADDRESS}/$8/g" \
        -e "s/\${DB_EXTERNAL_PORT}/$9/g" \
        docker/docker-compose-couchdb-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function generate_docker {
    _NETWORK_NAME=$1
    _ORGANIZATION_NAME=$2 
    _ORG_NAME=$3
    _DOMAIN_ADDRESS=$4
    _PEER_COUNT=$5
    _CORE_PEER_PORT=$6
    _LISTEN_PEER_PORT=$7
    _CORE_PEER_CHAINCODE_LISTEN_PORT=$8

    _DB_PORT=$9
    _DB_NAME=${10}
    _DB_USER=${11}
    _DB_PWD=${12}
    _DB_EXTERNAL_PORT=${13}

    # Generating Docker Compose Files Dynamically
    echo "$(docker_peer_yaml $_NETWORK_NAME $_ORGANIZATION_NAME $_ORG_NAME $_DOMAIN_ADDRESS $_PEER_COUNT $_CORE_PEER_PORT $_CORE_PEER_CHAINCODE_LISTEN_PORT $_LISTEN_PEER_PORT)" > ../organizations/peerOrganizations/docker-compose-${_ORG_NAME}-${_DOMAIN_ADDRESS}.yaml
    echo "$(docker_db_yaml $_NETWORK_NAME $_DB_NAME $_DB_PORT $_DB_USER $_DB_PWD $_PEER_COUNT $_ORG_NAME $_DOMAIN_ADDRESS $_DB_EXTERNAL_PORT)" > ../organizations/peerOrganizations/docker-compose-${_DB_NAME}${_PEER_COUNT}-${_ORG_NAME}-${_DOMAIN_ADDRESS}.yaml
}


