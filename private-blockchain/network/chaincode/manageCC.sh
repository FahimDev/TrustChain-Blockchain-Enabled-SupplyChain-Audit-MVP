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

    if [ ! -d "trustchain/node_modules" ]; then
        titleln "Chaincode's node modules not found, Performing 'npm install'"
        
	    cd trustchain && npm install && npm run build && cd -
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
    parsePeerConnectionParameters
    res=$?
    verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

    titleln "------>$PEER_CONN_PARMS"

    set -x
    peer lifecycle chaincode commit -o ${ORDERER_NODE_ADDRESS} --ordererTLSHostnameOverride ${ORDERER_ADDRESS} --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} $PEER_CONN_PARMS --version ${CC_VERSION} --sequence ${CC_SEQUENCE} ${INIT_REQUIRED} >&log.txt
    res=$?
    set +x
    cat log.txt
    verifyResult $res "Chaincode definition commit failed on peer0 of org${ORG} on channel '$CHANNEL_NAME' failed"
    successln "===================== Chaincode definition committed on channel '$CHANNEL_NAME' ===================== "
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
    parsePeerConnectionParameters 
    res=$?
    verifyResult $res "Invoke transaction failed on channel '$CHANNEL_NAME' due to uneven number of peer and org parameters "

    titleln "Invoking INIT function of chaincode"
    set -x
    fcn_call='{"function":"'${CC_INIT_FCN}'","Args":[]}'
    infoln "invoke fcn call:${fcn_call}"
    peer chaincode invoke -o ${ORDERER_NODE_ADDRESS} --ordererTLSHostnameOverride ${ORDERER_ADDRESS} --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN_PARMS --isInit -c ${fcn_call} >&log.txt
    res=$?
    set +x
    cat log.txt
    verifyResult $res "Invoke execution on $PEERS failed "
    successln "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
}

function setOrgGlobal {
    _ORG=$1
    _DOMAIN=$2
    _PEER=$3
    _PORT=$4
    _ORG_LC=`echo "${1,,}"`

    export CORE_PEER_LOCALMSPID="${_ORG}MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/../organizations/peerOrganizations/${_ORG_LC}.${_DOMAIN}/peers/peer${_PEER}.${_ORG_LC}.${_DOMAIN}/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=${PWD}/../organizations/peerOrganizations/${_ORG_LC}.${_DOMAIN}/users/Admin@${_ORG_LC}.${_DOMAIN}/msp
    export CORE_PEER_ADDRESS="localhost:$_PORT"
}

function parsePeerConnectionParameters {
    PEER_CONN_PARMS=""
    PEERS=""

    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        _PEER_ADDRESS="localhost:${CORE_PEER_PORTS[$i]}"
        _PEER0_ORG_CA=${PWD}/../organizations/peerOrganizations/${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/peers/peer${PEER_COUNT}.${_ORG_NAME_LC}.${ORG_DOMAINS[$i]}/tls/ca.crt
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT ${CORE_PEER_PORTS[$i]}

        PEER="peer0.${_ORG_NAME_LC}"
        echo "Joy Bangla ${ORGS[$i]}"

        PEERS="$PEERS $PEER"
        PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $_PEER_ADDRESS"
        TLSINFO=$(eval echo "--tlsRootCertFiles \$_PEER0_ORG_CA")
        PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    done
    
    PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

function init {
    ORDERER_CA=${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/${ORDERER_NAME}.${DOMAIN_ADDRESS}/msp/tlscacerts/tlsca.${DOMAIN_ADDRESS}-cert.pem
    
    # Package Chaincode
    packageChaincode
    
    # Install Chaincode
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT ${CORE_PEER_PORTS[$i]}

        installChaincode $_ORG_NAME_LC
    done

    # Query Chaincode is Installed
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT ${CORE_PEER_PORTS[$i]}

        queryChaincodeInstalled $_ORG_NAME_LC
    done

    # Approve for Org & check commit readiness for all orgs
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT ${CORE_PEER_PORTS[$i]}

        approveForMyOrg $_ORG_NAME_LC

        for i in "${!ORGS[@]}"; do
            _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
            setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT ${CORE_PEER_PORTS[$i]}

            checkCommitReadiness $_ORG_NAME_LC
        done
    done

    # Commit Chaincode Defination
    commitChaincodeDefinition 

    # Query Chaincode Defination Committed
    for i in "${!ORGS[@]}"; do
        _ORG_NAME_LC=`echo "${ORGS[$i],,}"`
        setOrgGlobal ${ORGS[$i]} ${ORG_DOMAINS[$i]} $PEER_COUNT ${CORE_PEER_PORTS[$i]}

        queryChaincodeDefinitionCommitted $_ORG_NAME_LC
    done

    # Invoke INIT function of chaincode
    invokeChaincodeINIT 
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