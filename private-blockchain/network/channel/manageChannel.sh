#!/bin/bash

. ../scripts/utils.sh

source ../root_config.sh

ORDERER_CA=${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/${ORDERER_NAME}.${DOMAIN_ADDRESS}/msp/tlscacerts/tlsca.${DOMAIN_ADDRESS}-cert.pem
ORDERER_ADDRESS=${ORDERER_NAME}.${DOMAIN_ADDRESS}

export FABRIC_CFG_PATH=${PWD}/../organizations/ordererOrganizations/configtx
export CORE_PEER_TLS_ENABLED=true


function createChannelTX {
    titleln "Generating ${CHANNEL_NAME}'s artifacts using ${PROFILE} profile"
    set -x
    configtxgen -profile $PROFILE -outputCreateChannelTx ../organizations/artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    res=$?
	{ set +x; } 2>/dev/null
    verifyResult $res "Failed to generate channel configuration transaction..."
}

function createChannelGenesisBlock {
    titleln "Creating ${CHANNEL_NAME}'s genesis block"
   
    sleep $DELAY
    peer channel create -o $ORDERER_NODE_ADDRESS -c $CHANNEL_NAME --ordererTLSHostnameOverride $ORDERER_ADDRESS -f ../organizations/artifacts/${CHANNEL_NAME}.tx --outputBlock ../organizations/artifacts/${CHANNEL_NAME}.block --tls --cafile $ORDERER_CA >&log.txt
    res=$?

	cat log.txt
	verifyResult $res "Channel creation failed"

    successln "Channel '$CHANNEL_NAME' created"
}

function joinChannel {
    titleln "Joining ${1} peer to the ${CHANNEL_NAME}"
    
    sleep $DELAY
    peer channel join -b ../organizations/artifacts/${CHANNEL_NAME}.block >&log.txt
	res=$?

	cat log.txt
	verifyResult $res "peer0.${1} has failed to join channel '$CHANNEL_NAME' "
    
    successln "Organization: $1 peer added to ${CHANNEL_NAME}"
    
    peer channel getinfo -c $CHANNEL_NAME
}

function setAnchorPeer {
    titleln "Setting anchor peer for $1"

    peer channel fetch config ../organizations/artifacts/config_block.pb -o $ORDERER_NODE_ADDRESS --ordererTLSHostnameOverride $ORDERER_ADDRESS -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

    configtxlator proto_decode --input ../organizations/artifacts/config_block.pb --type common.Block --output ../organizations/artifacts/config_block.json
    jq '.data.data[0].payload.data.config' ../organizations/artifacts/config_block.json > ../organizations/artifacts/config.json

    cp ../organizations/artifacts/config.json ../organizations/artifacts/config_copy.json
    
    jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'${2}'","port": '${3}'}]},"version": "0"}}' ../organizations/artifacts/config_copy.json > ../organizations/artifacts/modified_config.json

    configtxlator proto_encode --input ../organizations/artifacts/config.json --type common.Config --output ../organizations/artifacts/config.pb
    configtxlator proto_encode --input ../organizations/artifacts/modified_config.json --type common.Config --output ../organizations/artifacts/modified_config.pb
    configtxlator compute_update --channel_id $CHANNEL_NAME --original ../organizations/artifacts/config.pb --updated ../organizations/artifacts/modified_config.pb --output ../organizations/artifacts/config_update.pb

    configtxlator proto_decode --input ../organizations/artifacts/config_update.pb --type common.ConfigUpdate --output ../organizations/artifacts/config_update.json
    echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat ../organizations/artifacts/config_update.json)'}}}' | jq . > ../organizations/artifacts/config_update_in_envelope.json
    configtxlator proto_encode --input ../organizations/artifacts/config_update_in_envelope.json --type common.Envelope --output ../organizations/artifacts/config_update_in_envelope.pb

    peer channel update -f ../organizations/artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o $ORDERER_NODE_ADDRESS  --ordererTLSHostnameOverride $ORDERER_ADDRESS --tls --cafile $ORDERER_CA
    res=$?

    cat log.txt
	verifyResult $res "Failed to set anchor peer for $1"

    successln "Successfully set anchor peer for $1"

    peer channel getinfo -c $CHANNEL_NAME
}

function init {
    if [ ! -d "../organizations/artifacts" ]; then
	    mkdir ../organizations/artifacts
    fi

    for i in "${!ORGS[@]}"; do

        titleln "Setting Globals for ${ORGS[$i]}"
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/users/Admin@${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/msp
        export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../organizations/peerOrganizations/${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/peers/peer${PEER_COUNT}.${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/tls/ca.crt
        export CORE_PEER_LOCALMSPID="${ORGS[$i]}MSP"
        export CORE_PEER_ADDRESS=localhost:${CORE_PEER_PORTS[$i]}
        
        ORG=${ORGS[$i]}
        HOST=peer${PEER_COUNT}.${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}
        PORT=${CORE_PEER_PORTS[$i]}

        range=0;

        if [[ $i -eq $range ]]; then
            createChannelTX
            createChannelGenesisBlock
        fi
        joinChannel $ORG
        setAnchorPeer $ORG $HOST $PORT

    done 
}

function main {
    echo "Current Mode is $MODE"
    if [ "$MODE" == "init" ]; then
        CHANNEL_NAME="initchannel"
        PROFILE="BasicChannel"
        init
    else
        echo "Invalid Mode"
    fi
}

if [ $# -eq 0 ]; then
    echo "Please Insert Mode (init)"
else
    MODE=$1

    main
fi