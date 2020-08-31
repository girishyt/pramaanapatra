#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp_puc {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-puc.json
}

function yaml_ccp_puc {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-puc.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function json_ccp_eng {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-eng.json
}

function yaml_ccp_eng {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-eng.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function json_ccp_training {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-training.json
}

function yaml_ccp_training {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-training.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

function json_ccp_company {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-company.json
}

function yaml_ccp_company {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    #sed -e "s/\${ORG}/$1/" \
    sed -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template-company.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

#PUC
ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/puc.example.com/tlsca/tlsca.puc.example.com-cert.pem
CAPEM=organizations/peerOrganizations/puc.example.com/ca/ca.puc.example.com-cert.pem

echo "$(json_ccp_puc $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/puc.example.com/connection-puc.json
echo "$(yaml_ccp_puc $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/puc.example.com/connection-puc.yaml

#ENG
ORG=2
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/eng.example.com/tlsca/tlsca.eng.example.com-cert.pem
CAPEM=organizations/peerOrganizations/eng.example.com/ca/ca.eng.example.com-cert.pem

echo "$(json_ccp_eng $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/eng.example.com/connection-eng.json
echo "$(yaml_ccp_eng $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/eng.example.com/connection-eng.yaml

#TRAINING
ORG=3
P0PORT=9051
CAPORT=9054
PEERPEM=organizations/peerOrganizations/training.example.com/tlsca/tlsca.training.example.com-cert.pem
CAPEM=organizations/peerOrganizations/training.example.com/ca/ca.training.example.com-cert.pem

echo "$(json_ccp_training $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/training.example.com/connection-training.json
echo "$(yaml_ccp_training $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/training.example.com/connection-training.yaml

#COMPANY
ORG=4
P0PORT=10051
CAPORT=10054
PEERPEM=organizations/peerOrganizations/company.example.com/tlsca/tlsca.company.example.com-cert.pem
CAPEM=organizations/peerOrganizations/company.example.com/ca/ca.company.example.com-cert.pem

echo "$(json_ccp_company $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/company.example.com/connection-company.json
echo "$(yaml_ccp_company $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/company.example.com/connection-company.yaml