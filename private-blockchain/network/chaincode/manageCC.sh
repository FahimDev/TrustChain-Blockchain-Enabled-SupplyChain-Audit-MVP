#!/bin/bash

source ../root_config.sh

. ../scripts/utils.sh

export FABRIC_CFG_PATH=${PWD}/../organizations/ordererOrganizations/configtx
export CORE_PEER_TLS_ENABLED=true

function packageChaincode {
    titleln "Packaging the Chaincode"

    set -x
    peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}_${CC_VERSION} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode packaging has failed"
    successln "'${CC_NAME}' Chaincode is packaged"
}

function installChaincode {
    pORG=$1
    
    titleln "Installing chaincode on peer0.${pORG}"

    if [ ! -d "fabcar/node_modules" ]; then
        titleln "Chaincode's node modules not found, Performing 'npm install'"
        
	    cd fabcar && npm install && npm run build && cd -
    fi

    set -x
    peer lifecycle chaincode install ${CC_NAME}.tar.gz >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode installation on peer0.${pORG} has failed"
    successln "Chaincode is installed on peer0.${pORG}"
}

function queryChaincodeInstalled {
    pORG=$1

    titleln "Querying if chaincode installed on peer0.${pORG}"

    set -x
    peer lifecycle chaincode queryinstalled >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    verifyResult $res "Query installed on peer0.${pORG} has failed"
    successln "Chaincode installed successful on peer0.${pORG}"
}

function approveForMyOrg {
    pORG=$1

    titleln "Approving chaincode defination on peer0.${pORG}"

    set -x
    peer lifecycle chaincode approveformyorg -o ${ORDERER_NODE_ADDRESS} --ordererTLSHostnameOverride ${ORDERER_ADDRESS} --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --package-id ${PACKAGE_ID} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition approved on peer0.${pORG} on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition approved on peer0.${pORG} on channel '$CHANNEL_NAME'"
}

function checkCommitReadiness {
    pORG=$1

    titleln "Checking the commit readiness of the chaincode definition on peer0.${pORG} on channel '$CHANNEL_NAME'"

    infoln "sleeping for ${DELAY} secs"
    sleep $DELAY
    set -x
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} --output json >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Check commit readiness result on peer0.${pORG} is INVALID!"
    successln "Checking the commit readiness of the chaincode definition successful on peer0.${pORG} on channel '$CHANNEL_NAME'"
}

function commitChaincodeDefinition {
    pORG=$1

    titleln "Committing chaincode definition on peer0.${pORG} on channel '$CHANNEL_NAME'"

    set -x
    peer lifecycle chaincode commit -o ${ORDERER_NODE_ADDRESS} --ordererTLSHostnameOverride ${ORDERER_ADDRESS} --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Chaincode definition commit failed on peer0.${pORG} on channel '$CHANNEL_NAME' failed"
    successln "Chaincode definition committed on peer0.${pORG} channel '$CHANNEL_NAME'"
}

function queryChaincodeDefinitionCommitted {
    pORG=$1
    
    titleln "Querying chaincode definition on peer0.${pORG} on channel '$CHANNEL_NAME'"

    infoln "sleeping for ${DELAY} secs"
    sleep $DELAY
    infoln "Attempting to Query committed status on peer0.${pORG}"
    set -x
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&log.txt
    res=$?
    cat log.txt
    verifyResult $res "Query chaincode definition result on peer0.${pORG} on '${CHANNEL_NAME}' is INVALID!"
    successln "Query chaincode definition successful on peer0.${pORG} on channel '$CHANNEL_NAME'"
}

function invokeChaincodeINIT {
    pORG=$1

    titleln "Invoking INIT function of chaincode"
    set -x
    fcn_call='{"function":"'${CC_INIT_FCN}'","Args":[]}'
    infoln "invoke fcn call:${fcn_call}"
    peer chaincode invoke -o ${ORDERER_NODE_ADDRESS} --ordererTLSHostnameOverride ${ORDERER_ADDRESS} --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} --peerAddresses ${CORE_PEER_ADDRESS} --tlsRootCertFiles ${CORE_PEER_TLS_ROOTCERT_FILE} --isInit -c ${fcn_call} >&log.txt
    res=$?
    { set +x; } 2>/dev/null
    cat log.txt
    verifyResult $res "Invoke execution on peer0.${pORG} failed "
    successln "Invoke transaction successful on ${pORG} on channel '$CHANNEL_NAME'"
}

function setOrgGlobal {
    _ORG=$1
    _DOMAIN=$2
    _PEER=$3
    _ORG_LC=`echo "${i,,}"`

    export CORE_PEER_LOCALMSPID="${_ORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../organizations/peerOrganizations/${_ORG_LC}.${DOMAIN}/peers/peer${_PEER}.${_ORG_LC}.${_DOMAIN}/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/${_ORG_LC}.${DOMAIN}/users/Admin@${_ORG_LC}.${_DOMAIN}/msp
}

function init {
    ORDERER_CA=${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/${ORDERER_NAME}.${DOMAIN_ADDRESS}/msp/tlscacerts/tlsca.${DOMAIN_ADDRESS}-cert.pem

    packageChaincode
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT

        installChaincode $_ORG_NAME_LC
    done

    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT

        queryChaincodeInstalled $_ORG_NAME_LC
        approveForMyOrg $_ORG_NAME_LC
    done

    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT

        checkCommitReadiness $_ORG_NAME_LC
    done

    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT

        commitChaincodeDefinition $_ORG_NAME_LC
    done

    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT

        queryChaincodeDefinitionCommitted $_ORG_NAME_LC
    done

    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT

        invokeChaincodeINIT $_ORG_NAME_LC
    done
}

function clean {
    docker rm $(docker ps -a | grep dev-peer0.${NEW_ORG_NAME}.${DOMAIN_ADDRESS}-${CC_NAME}_1.0 | awk '{print $1}')
    rm ${CC_NAME}.tar.gz
    rm log.txt
}

function main {
    echo "Current Mode is $MODE"
    if [ "$MODE" == "init" ]; then
        init
    elif [ "$MODE" == "clean" ]; then
        clean
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