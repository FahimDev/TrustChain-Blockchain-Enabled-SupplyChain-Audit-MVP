#!/bin/bash

source ../root_config.sh

function newLine {
    printf "\n" >> configtx.yaml
}

function yaml_org {
    ORG_NAME_LC=`echo "${1,,}"`
    sed -e "s/\${ORG_NAME}/$1/g" \
        -e "s/\${DOMAIN}/$2/g" \
        -e "s/\${ORG_NAME_LS}/$ORG_NAME_LC/g" \
        templates/org.yaml
}

function yaml_orderer_org {
    ORDERER_NAME_LC=`echo "${1,,}"`
    sed -e "s/\${ORDERER_NAME}/$1/g" \
        -e "s/\${DOMAIN}/$2/g" \
        -e "s/\${SAF}/$3/g" \
        -e "s/\${ORDERER_LISTEN_PORT}/${ORDERER_LISTEN_PORT}/g" \
        -e "s/\${ORDERER_NAME_LC}/$ORDERER_NAME_LC/g" \
        templates/orderer-org.yaml
}

function yaml_orderer {
    ORDERER_NAME_LC=`echo "${1,,}"`
    sed -e "s/\${ORDERER_NAME_LC}/$ORDERER_NAME_LC/g" \
        -e "s/\${DOMAIN}/$2/g" \
        templates/orderer-org.yaml
}

function yaml_consenter {
    ORDERER_NAME_LC=`echo "${1,,}"`
    sed -e "s/\${ORDERER_NAME}/$1/g" \
        -e "s/\${DOMAIN}/$2/g" \
        -e "s/\${PORT}/$3/g" \
        -e "s/\${ORDERER_NAME_LC}/$ORDERER_NAME_LC/g" \
        templates/consenter.yaml
}

function yaml_orderer_profile {
    sed -e "s/\${NAME}/$1/g" \
        templates/orderer-profile.yaml
}

function yaml_channel_profile {
    sed -e "s/\${NAME}/$1/g" \
        -e "s/\${CONSORTIUM}/$2/g" \
        templates/channel-profile.yaml
}

function generatePeerOrgs {
    for i in "${!ORGS[@]}"; do 
        ORG_NAME="${ORGS[$i]}"
        DOMAIN="${ORG_DOMAINS[$i]}"
        echo "$(yaml_org $ORG_NAME $DOMAIN)" >> configtx.yaml
    done
}

function generateOrdererOrgs {
    SAF=false
    for i in "${!ORDERERS[@]}"; do 
        ORDERER_NAME="${ORDERERS[$i]}"
        DOMAIN="${ORDERER_DOMAINS[$i]}"
        echo "$(yaml_orderer_org $ORDERER_NAME $DOMAIN $SAF)" >> configtx.yaml
    done
}

function generateOrderAddresses {
    STR="\\"
    START_PORT=7050
    for i in "${!ORDERERS[@]}"; do
        PORT=$(($START_PORT + (1000 * $i)))
        ORDERER_NAME_LC=`echo "${ORDERERS[$i],,}"`
        STR="${STR}      - ${ORDERER_NAME_LC}.${ORDERER_DOMAINS[$i]}:${PORT}\n"
    done
    printf "$(sed "/Addresses:/a $STR" configtx.yaml)" > configtx.yaml
}

function generateOrderConsenters {
    STR=""
    START_PORT=7050
    for i in "${!ORDERERS[@]}"; do
        PORT=$(($START_PORT + (1000 * $i)))
        DOMAIN="${ORDERER_DOMAINS[$i]}"
        ORDERER_NAME="${ORDERERS[$i]}"
        STR="${STR}$(echo "$(yaml_consenter $ORDERER_NAME $DOMAIN $PORT)")"
        STR="${STR}"$'\n'
    done
    echo "${STR}" > temp.yaml
    printf "$(sed "/Consenters:/r temp.yaml" configtx.yaml)" > configtx.yaml
    rm temp.yaml
}

function generateOrdererProfile {
    _NAME=$1
    local -n _ORDERERS=$2
    local -n _ORGS=$3

    echo "$(yaml_orderer_profile $_NAME)" >> temp.yaml
    STR="\\"
    for i in "${!_ORDERERS[@]}"; do
        STR="${STR}              - <<: *${_ORDERERS[$i]}Org\n"
    done

    printf "$(sed "/Organizations:/a $STR" temp.yaml)" > temp.yaml

    CON_NAME="BasicConsortium"
    generateOrdererConsortium $CON_NAME _ORGS

    cat temp.yaml >> configtx.yaml
    rm temp.yaml
}

function generateChannelProfile {
    _NAME=$1
    _CONSORTIUM=$2
    local -n _ORGS=$3

    echo "$(yaml_channel_profile $_NAME $_CONSORTIUM )" > temp.yaml
    STR="\\"
    for i in "${!_ORGS[@]}"; do
        STR="${STR}                    - *${_ORGS[$i]}\n"
    done

    printf "$(sed "/Organizations:/a $STR" temp.yaml)" > temp.yaml

    cat temp.yaml >> configtx.yaml
    rm temp.yaml
}

function generateOrdererConsortium {
    _NAME=$1
    local -n _GORGS=$2

    echo "\n            $_NAME:" > con_temp.yaml
    echo "                Organizations:" >> con_temp.yaml
    STR="\\"
    for i in "${!_GORGS[@]}"; do
        STR="${STR}                    - <<: *${_GORGS[$i]}\n"
    done

    printf "$(sed "/Organizations:/a $STR" con_temp.yaml)" > con_temp.yaml
    cat con_temp.yaml >> temp.yaml

    rm con_temp.yaml
}

function generateOrgs {
    echo "Organizations:" >> configtx.yaml
    generateOrdererOrgs
    generatePeerOrgs
}

function generateCapabilities {
    newLine
    cat templates/capabilities.yaml >> configtx.yaml
}

function generateApplication {
    newLine
    newLine
    cat templates/application.yaml >> configtx.yaml
}

function generateOrderDefaults {
    newLine
    newLine
    cat templates/orderer.yaml >> configtx.yaml

    generateOrderAddresses
    generateOrderConsenters
}

function generateChannelDefaults {
    newLine
    newLine
    cat templates/channel.yaml >> configtx.yaml
}

function generateProfiles {
    newLine
    newLine
    echo "Profiles:" >> configtx.yaml
    NAME="OrdererGenesis"
    generateOrdererProfile $NAME ORDERERS ORGS
    
    NAME="BasicChannel"
    CONSORTIUM="BasicConsortium"
    newLine
    generateChannelProfile $NAME $CONSORTIUM ORGS
}

truncate -s 0 configtx.yaml

generateOrgs
generateCapabilities
generateApplication
generateOrderDefaults
generateChannelDefaults
generateProfiles

mkdir -p ../organizations/ordererOrganizations/configtx

cp configtx.yaml ../organizations/ordererOrganizations/configtx
cp core.yaml ../organizations/ordererOrganizations/configtx
