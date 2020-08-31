

function createPuc {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/puc.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/puc.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-puc --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-puc.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-puc.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-puc.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-puc.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/puc.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-puc --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-puc --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-puc --id.name pucadmin --id.secret pucadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/puc.example.com/peers
  mkdir -p organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-puc -M ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/msp --csr.hosts peer0.puc.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/puc.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-puc -M ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls --enrollment.profile tls --csr.hosts peer0.puc.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/puc.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/puc.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/puc.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/puc.example.com/tlsca/tlsca.puc.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/puc.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/puc.example.com/peers/peer0.puc.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/puc.example.com/ca/ca.puc.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/puc.example.com/users
  mkdir -p organizations/peerOrganizations/puc.example.com/users/User1@puc.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-puc -M ${PWD}/organizations/peerOrganizations/puc.example.com/users/User1@puc.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/puc.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/puc.example.com/users/User1@puc.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/puc.example.com/users/Admin@puc.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://pucadmin:pucadminpw@localhost:7054 --caname ca-puc -M ${PWD}/organizations/peerOrganizations/puc.example.com/users/Admin@puc.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/puc/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/puc.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/puc.example.com/users/Admin@puc.example.com/msp/config.yaml

}

function createEng {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/eng.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/eng.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-eng --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-eng.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-eng.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-eng.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-eng.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/eng.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-eng --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-eng --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-eng --id.name engadmin --id.secret engadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/eng.example.com/peers
  mkdir -p organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-eng -M ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/msp --csr.hosts peer0.eng.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/eng.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-eng -M ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls --enrollment.profile tls --csr.hosts peer0.eng.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/eng.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/eng.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/eng.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/eng.example.com/tlsca/tlsca.eng.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/eng.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/eng.example.com/peers/peer0.eng.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/eng.example.com/ca/ca.eng.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/eng.example.com/users
  mkdir -p organizations/peerOrganizations/eng.example.com/users/User1@eng.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-eng -M ${PWD}/organizations/peerOrganizations/eng.example.com/users/User1@eng.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/eng.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/eng.example.com/users/User1@eng.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/eng.example.com/users/Admin@eng.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://engadmin:engadminpw@localhost:8054 --caname ca-eng -M ${PWD}/organizations/peerOrganizations/eng.example.com/users/Admin@eng.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/eng/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/eng.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/eng.example.com/users/Admin@eng.example.com/msp/config.yaml

}

function createTraining {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/training.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/training.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-training --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-training.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-training.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-training.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-training.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/training.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-training --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-training --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-training --id.name trainingadmin --id.secret trainingadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/training.example.com/peers
  mkdir -p organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-training -M ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/msp --csr.hosts peer0.training.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/training.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-training -M ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls --enrollment.profile tls --csr.hosts peer0.training.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/training.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/training.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/training.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/training.example.com/tlsca/tlsca.training.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/training.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/training.example.com/peers/peer0.training.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/training.example.com/ca/ca.training.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/training.example.com/users
  mkdir -p organizations/peerOrganizations/training.example.com/users/User1@training.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-training -M ${PWD}/organizations/peerOrganizations/training.example.com/users/User1@training.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/training.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/training.example.com/users/User1@training.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/training.example.com/users/Admin@training.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://trainingadmin:trainingadminpw@localhost:9054 --caname ca-training -M ${PWD}/organizations/peerOrganizations/training.example.com/users/Admin@training.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/training/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/training.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/training.example.com/users/Admin@training.example.com/msp/config.yaml

}

function createCompany {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/peerOrganizations/company.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/company.example.com/
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-company --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-company.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-company.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-company.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-company.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/peerOrganizations/company.example.com/msp/config.yaml

  echo
	echo "Register peer0"
  echo
  set -x
	fabric-ca-client register --caname ca-company --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

  echo
  echo "Register user"
  echo
  set -x
  fabric-ca-client register --caname ca-company --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

  echo
  echo "Register the org admin"
  echo
  set -x
  fabric-ca-client register --caname ca-company --id.name companyadmin --id.secret companyadminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

	mkdir -p organizations/peerOrganizations/company.example.com/peers
  mkdir -p organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com

  echo
  echo "## Generate the peer0 msp"
  echo
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-company -M ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/msp --csr.hosts peer0.company.example.com --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/company.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10054 --caname ca-company -M ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls --enrollment.profile tls --csr.hosts peer0.company.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x


  cp ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/company.example.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/company.example.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/company.example.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/company.example.com/tlsca/tlsca.company.example.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/company.example.com/ca
  cp ${PWD}/organizations/peerOrganizations/company.example.com/peers/peer0.company.example.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/company.example.com/ca/ca.company.example.com-cert.pem

  mkdir -p organizations/peerOrganizations/company.example.com/users
  mkdir -p organizations/peerOrganizations/company.example.com/users/User1@company.example.com

  echo
  echo "## Generate the user msp"
  echo
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:10054 --caname ca-company -M ${PWD}/organizations/peerOrganizations/company.example.com/users/User1@company.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/company.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/company.example.com/users/User1@company.example.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/company.example.com/users/Admin@company.example.com

  echo
  echo "## Generate the org admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://companyadmin:companyadminpw@localhost:10054 --caname ca-company -M ${PWD}/organizations/peerOrganizations/company.example.com/users/Admin@company.example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/company/tls-cert.pem
  set +x

  cp ${PWD}/organizations/peerOrganizations/company.example.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/company.example.com/users/Admin@company.example.com/msp/config.yaml

}

function createOrderer {

  echo
	echo "Enroll the CA admin"
  echo
	mkdir -p organizations/ordererOrganizations/example.com

	export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com
#  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
#  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml


  echo
	echo "Register orderer"
  echo
  set -x
	fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
    set +x

  echo
  echo "Register the orderer admin"
  echo
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

	mkdir -p organizations/ordererOrganizations/example.com/orderers
  mkdir -p organizations/ordererOrganizations/example.com/orderers/example.com

  mkdir -p organizations/ordererOrganizations/example.com/orderers/orderer.example.com

  echo
  echo "## Generate the orderer msp"
  echo
  set -x
	fabric-ca-client enroll -u https://orderer:ordererpw@localhost:11054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:11054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

  mkdir -p organizations/ordererOrganizations/example.com/users
  mkdir -p organizations/ordererOrganizations/example.com/users/Admin@example.com

  echo
  echo "## Generate the admin msp"
  echo
  set -x
	fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:11054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  set +x

  cp ${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml


}
