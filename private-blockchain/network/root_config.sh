NETWORK_NAME="fabric_test"
ORGS=(Manufacturer Inventory)
ORG_DOMAINS=("brainstation23.com" "brainstation23.com")
CORE_PEER_PORTS=(7051 8051)
LISTEN_PEER_PORTS=(17051 18051)
CORE_PEER_CHAINCODE_LISTEN_PORTS=(7052 8052)

CA_CORE_PEER_PORT=(7054 8054)
CA_LISTEN_PEER_PORTS=(17054 18054)

DOMAIN_ADDRESS="brainstation23.com" 
PEER_COUNT="0"
CORE_PEER_PORT=7051
export CORE_PEER_ADDRESS=localhost:7051
CORE_PEER_CHAINCODE_LISTEN_PORT=7052
LISTEN_PEER_PORT=17051
ORG_CA_NAME="ca-teq1"
ORG_ADMIN="org1admin"
ORG_ADMIN_PWD="org1adminpw"
ORG_USER="admin"
ORG_PWD="adminpw"
ORG_PEER_USER="peer0"
ORG_PEER_PWD="peer0pw"
ORG_CLIENT_USER="user1"
ORG_CLIENT_PWD="user1pw"

DB_NAME="couchdb" 
DB_EXTERNAL_PORT=5984
DB_PORTS=(5984 7984)
DB_USER="admin"
DB_PWD="adminpw"

CA_CORE_PEER_PORT=7054
CA_LISTEN_PEER_PORT=17054
CA_USER="admin"
CA_PWD="adminpw"
CA_CORE_ORDERER_PORT=9054
CA_CORE_ORDERER_LISTEN_PORT=19054

ORDERER_LISTEN_PORT=7050
ORDERER_NODE_ADDRESS="localhost:7050"
ORDERER_OPERATION_LISTEN_PORT=9443
# Will be used during the generating process of Orderer MSP | TLS certificates
ORDERER_CA_NAME="ca-orderer"
ORDERER_CAP_NAME="Orderer"
ORDERER_NAME="orderer"
ORDERER_CONFIG_NAME="OrdererOrg"
ORDERER_MSP_ID="OrdererMSP"
ORDERER_USER="orderer"
ORDERER_PWD="ordererpw"
ORDERER_ADMIN="ordererAdmin"
ORDERER_ADMIN_PWD="ordererAdminpw"

# Chaincode

CC_NAME="fabcar"
CC_SRC_PATH=${PWD}/fabcar
CC_RUNTIME_LANGUAGE="node"
CC_VERSION="1.0"
CC_SEQUENCE=1
CC_INIT_FCN="initLedger"
PACKAGE_ID=""
ORDERER_ADDRESS=${ORDERER_NAME}.${DOMAIN_ADDRESS}
INIT_REQUIRED="--init-required"


CHANNEL_NAME="initchannel" # Channel Name has to be all lowercase
DELAY="5"
PROFILE="BasicChannel"




