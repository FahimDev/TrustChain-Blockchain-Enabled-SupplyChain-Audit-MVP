#!/bin/bash

export PATH=${PWD}/bin:${PWD}:$PATH

starttime=$(date +%s)
MODE="Down"
EOF_P_MESSAGE="PROCESS FINISHED"

source root_config.sh

function networkUp {

    pushd _dynamic-config 
        echo "Currently at ${PWD}"
        ./manageConfig.sh
    popd
 
    pushd fabric-ca 
        echo "Currently at ${PWD}"
        ./manageCA.sh generate
        ./manageCA.sh up orderer
        ./manageCA.sh up org
    popd

    pushd org-config 
        echo "Currently at ${PWD}"
        ./manageOrg.sh generate
        ./manageOrg.sh up
    popd

    # pushd orderer
    #     echo "Currently at ${PWD}"
    #     ./scripts/setup-env.sh
    #     ./scripts/create-orderer.sh
    #     ./scripts/generate-system-genesis-block.sh
    #     ./scripts/start-orderer.sh
    # popd

    pushd orderer-config
        echo "Currently at ${PWD}"
        ./manageOrderer.sh generate
        ./manageOrderer.sh up
    popd

    pushd channel
        echo "Currently at ${PWD}"
        ./manageChannel.sh init
    popd

    # pushd chaincode
    #     echo "Currently at ${PWD}"
    #     ./manageCC.sh init
    # popd
}

function networkDown {

    pushd fabric-ca
        echo "Currently at ${PWD}"
        ./manageCA.sh down
    popd

    pushd orderer-config
        echo "Currently at ${PWD}"
        ./manageOrg.sh down
    popd

    pushd org-config
        echo "Currently at ${PWD}"
        ./manageOrg.sh down
    popd

    pushd chaincode
        echo "Currently at ${PWD}"
        ./manageCC.sh clean
    popd

    rm -r system-genesis-block
    rm -r channel/artifacts
    rm channel/log.txt
    rm -r fabric-ca/temp
    rm -r organizations
}

function main {
    echo "Current Mode is $MODE"
    if [ "$MODE" == "up" ]; then
        EOF_P_MESSAGE="PROCESS FINISHED"
        networkUp
    elif [ "$MODE" == "down" ]; then
        EOF_P_MESSAGE=" NETWORK DOWNED "
        networkDown
    else
        echo "Invalid Mode"
    fi
}

if [ $# -eq 0 ]; then
    echo "Please Insert Mode (up or down)"
else
    MODE=$1

    main
fi

cat <<EOF

============================================================================
Total setup execution time : $(($(date +%s) - starttime)) secs ...
============================================================================
============================= ${EOF_P_MESSAGE} =============================
============================================================================
EOF