#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt

export PEER0_PUC_CA=${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/ca.crt
export PEER0_ENG_CA=${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/ca.crt
export PEER0_TRAINING_CA=${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/ca.crt
export PEER0_COMPANY_CA=${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  echo "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    #Girish: Mapping 1 to PUC org
    export CORE_PEER_LOCALMSPID="PucMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PUC_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/puc.example.com/users/Admin@puc.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
    #Girish: Mapping 2 to ENG org
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="EngMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ENG_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/eng.example.com/users/Admin@eng.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    #Girish: mapping 3 to TrainingMSP
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="TrainingMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_TRAINING_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/training.example.com/users/Admin@training.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    #Girish: mapping 4 to CompanyMSP
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="CompanyMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COMPANY_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/company.example.com/users/Admin@company.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
  else
    echo "================== ERROR !!! ORG Unknown =================="
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    if [ $1 -eq 1 ]; then
      PEER="peer0.puc"
      echo "After setGlobals for ${PEER}";
      ## Set peer adresses
      PEERS="$PEERS $PEER"
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
      ## Set path to TLS certificate
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_PUC_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    elif [ $1 -eq 2 ]; then
      PEER="peer0.eng"
      echo "After setGlobals for ${PEER}";
      ## Set peer adresses
      PEERS="$PEERS $PEER"
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
      ## Set path to TLS certificate
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ENG_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    elif [ $1 -eq 3 ]; then
      PEER="peer0.training"
      echo "After setGlobals for ${PEER}";
      ## Set peer adresses
      PEERS="$PEERS $PEER"
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
      ## Set path to TLS certificate
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_TRAINING_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    elif [ $1 -eq 4 ]; then
      PEER="peer0.company"
      echo "After setGlobals for ${PEER}";
      ## Set peer adresses
      PEERS="$PEERS $PEER"
      PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
      ## Set path to TLS certificate
      TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_COMPANY_CA")
      PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    else
      echo "================== ERROR !!! ORG Unknown =================="
    fi
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    echo $'\e[1;31m'!!!!!!!!!!!!!!! $2 !!!!!!!!!!!!!!!!$'\e[0m'
    echo
    exit 1
  fi
}
