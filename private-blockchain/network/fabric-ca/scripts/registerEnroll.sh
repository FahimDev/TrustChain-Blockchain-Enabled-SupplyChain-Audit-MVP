#!/bin/bash

source ../root_config.sh

function createOrdererCA() {
  echo "Enrolling the CA admin"
  # mkdir -p ../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp

  export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}

  set -x
  fabric-ca-client enroll -u https://${CA_USER}:${CA_PWD}@localhost:${CA_CORE_ORDERER_PORT} --caname ${ORDERER_CA_NAME} --tls.certfiles ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  # Organizational Units (OUs) Ref: https://hyperledger-fabric.readthedocs.io/en/release-2.5/membership/membership.html#node-ou-roles-and-msps
  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-$CA_CORE_ORDERER_PORT-$ORDERER_CA_NAME.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-$CA_CORE_ORDERER_PORT-$ORDERER_CA_NAME.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-$CA_CORE_ORDERER_PORT-$ORDERER_CA_NAME.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-$CA_CORE_ORDERER_PORT-$ORDERER_CA_NAME.pem
    OrganizationalUnitIdentifier: orderer" >${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/msp/config.yaml

  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ${ORDERER_CA_NAME} --id.name ${ORDERER_USER} --id.secret ${ORDERER_PWD} --id.type orderer --tls.certfiles ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ${ORDERER_CA_NAME} --id.name ${ORDERER_ADMIN} --id.secret ${ORDERER_ADMIN_PWD} --id.type admin --tls.certfiles ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://${ORDERER_USER}:${ORDERER_PWD}@localhost:${CA_CORE_ORDERER_PORT} --caname ${ORDERER_CA_NAME} -M ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/msp --csr.hosts orderer.${DOMAIN_ADDRESS} --csr.hosts localhost --tls.certfiles ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/msp/config.yaml ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/msp/config.yaml

  echo "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${ORDERER_USER}:${ORDERER_PWD}@localhost:${CA_CORE_ORDERER_PORT} --caname ${ORDERER_CA_NAME} -M ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls --enrollment.profile tls --csr.hosts orderer.${DOMAIN_ADDRESS} --csr.hosts localhost --tls.certfiles ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/tlscacerts/* ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/ca.crt
  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/signcerts/* ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/server.crt
  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/keystore/* ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/server.key

  mkdir -p ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/msp/tlscacerts
  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/tlscacerts/* ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/msp/tlscacerts/tlsca.${DOMAIN_ADDRESS}-cert.pem

  mkdir -p ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/msp/tlscacerts
  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/orderers/orderer.${DOMAIN_ADDRESS}/tls/tlscacerts/* ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/msp/tlscacerts/tlsca.${DOMAIN_ADDRESS}-cert.pem

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://${ORDERER_ADMIN}:${ORDERER_ADMIN_PWD}@localhost:${CA_CORE_ORDERER_PORT} --caname ${ORDERER_CA_NAME} -M ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/users/Admin@${DOMAIN_ADDRESS}/msp --tls.certfiles ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/ca-temp/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/msp/config.yaml ${PWD}/../organizations/ordererOrganizations/${DOMAIN_ADDRESS}/users/Admin@${DOMAIN_ADDRESS}/msp/config.yaml
}

function createOrgCA() {
  _ORG_NAME=$1
  _DOMAIN=$2
  _CA_CORE_PEER_PORT=$3
  _ORG_CA_NAME="ca-${_ORG_NAME}"
  
  echo "Enrolling the CA admin"
  # mkdir -p ../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp

  export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/

  set -x
  fabric-ca-client enroll -u https://${ORG_USER}:${ORG_PWD}@localhost:${_CA_CORE_PEER_PORT} --caname ${_ORG_CA_NAME} --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-$_CA_CORE_PEER_PORT-$_ORG_CA_NAME.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-$_CA_CORE_PEER_PORT-$_ORG_CA_NAME.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-$_CA_CORE_PEER_PORT-$_ORG_CA_NAME.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-$_CA_CORE_PEER_PORT-$_ORG_CA_NAME.pem
    OrganizationalUnitIdentifier: orderer" >${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/msp/config.yaml

  echo "Registering peer${PEER_COUNT}"
  set -x
  fabric-ca-client register --caname ${_ORG_CA_NAME} --id.name ${ORG_PEER_USER} --id.secret ${ORG_PEER_PWD} --id.type peer --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ${_ORG_CA_NAME} --id.name ${ORG_CLIENT_USER} --id.secret ${ORG_CLIENT_PWD} --id.type client --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Registering the ${_ORG_NAME} admin"
  set -x
  fabric-ca-client register --caname ${_ORG_CA_NAME} --id.name ${ORG_ADMIN} --id.secret ${ORG_ADMIN_PWD} --id.type admin --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  echo "Generating the peer${PEER_COUNT} msp"
  set -x
  fabric-ca-client enroll -u https://${ORG_PEER_USER}:${ORG_PEER_PWD}@localhost:${_CA_CORE_PEER_PORT} --caname ${_ORG_CA_NAME} -M ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/msp --csr.hosts peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN} --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/msp/config.yaml ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/msp/config.yaml

  echo "Generating the peer${PEER_COUNT}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${ORG_PEER_USER}:${ORG_PEER_PWD}@localhost:${_CA_CORE_PEER_PORT} --caname ${_ORG_CA_NAME} -M ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls --enrollment.profile tls --csr.hosts peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN} --csr.hosts localhost --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/ca.crt
  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/signcerts/* ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/server.crt
  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/keystore/* ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/server.key

  mkdir -p ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/msp/tlscacerts
  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/tlsca
  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/tls/tlscacerts/* ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/tlsca/tlsca.${_ORG_NAME}.${_DOMAIN}-cert.pem

  mkdir -p ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca
  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/peers/peer${PEER_COUNT}.${_ORG_NAME}.${_DOMAIN}/msp/cacerts/* ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca/ca.${_ORG_NAME}.${_DOMAIN}-cert.pem

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://${ORG_CLIENT_USER}:${ORG_CLIENT_PWD}@localhost:${_CA_CORE_PEER_PORT} --caname ${_ORG_CA_NAME} -M ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/users/User1@${_ORG_NAME}.${_DOMAIN}/msp --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/msp/config.yaml ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/users/User1@${_ORG_NAME}.${_DOMAIN}/msp/config.yaml

  echo "Generating the ${_ORG_NAME} admin msp"
  set -x
  fabric-ca-client enroll -u https://${ORG_ADMIN}:${ORG_ADMIN_PWD}@localhost:${_CA_CORE_PEER_PORT} --caname ${_ORG_CA_NAME} -M ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/users/Admin@${_ORG_NAME}.${_DOMAIN}/msp --tls.certfiles ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/ca-temp/${_ORG_NAME}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/msp/config.yaml ${PWD}/../organizations/peerOrganizations/${_ORG_NAME}.${_DOMAIN}/users/Admin@${_ORG_NAME}.${_DOMAIN}/msp/config.yaml
}