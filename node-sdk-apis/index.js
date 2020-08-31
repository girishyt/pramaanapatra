
'use strict';

const express = require('express')
const app = express()
const port = 3000

var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended:true }));

const {Gateway, Wallets} = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const {buildCAClient, registerUser, enrollAdmin} = require('./CAUtil.js');
const {buildCCP, buildWallet} = require('./AppUtil.js');

const channelName = 'mychannel';
const chaincodeName = 'certificate';

const userId = 'appUser2';

// build an in memory object with the network configuration (also known as a connection profile)
let ccp;

// build an instance of the fabric ca services client based on
// the information in the network configuration
let caClient;

// setup the wallet to hold the credentials of the application user
let wallet;

let globalOrg;

async function initializeApp(res,org){
    try{
        var walletPath = path.join(__dirname, 'wallet');
        globalOrg = org;
        ccp = buildCCP(org);
        caClient = buildCAClient(FabricCAServices, ccp, org);
        walletPath = path.join(walletPath,org);
        wallet = await buildWallet(Wallets, walletPath);
        res.send("App initilized for "+org);
    }
    catch (error) {
        console.error(`******** FAILED to initialize the application: ${error}`);
        throw new Error(`******** FAILED to initialize the application: ${error}`);
	}
    
}

async function enrollAdminFunc(res){
    try{
        await enrollAdmin(caClient, wallet);
        console.log('Admin Enrolled for the org: '+globalOrg);
        res.send('Admin Enrolled for the org: '+globalOrg);
    }
    catch(error){
        console.error(`FAILED to enroll the admin for the org:${globalOrg} ${error}`);
        throw new Error(error);
    }
}

async function registerUserFunc(res,userId,department){
    try{
        await registerUser(caClient, wallet, userId, globalOrg+'.'+department);
        console.log('User '+userId+' is successfully registered in '+globalOrg+'.'+department);
        res.send('User '+userId+' is successfully registered in '+globalOrg+'.'+department);
    }
    catch(error){
        console.error(`FAILED to register the user ${userId} for the org:${globalOrg} ${error}`);
        throw new Error(error);
    }
}

async function getStudent(res,user,studentId) {
    const gateway = new Gateway();
    try{
        await gateway.connect(ccp, {
            wallet,
            identity: user,
            discovery: {enabled: true, asLocalhost: true} // using asLocalhost as this gateway is using a fabric network deployed locally
        });

        // Build a network instance based on the channel where the smart contract is deployed
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);

        // Initialize a set of asset data on the channel using the chaincode 'InitLedger' function.
        // This type of transaction would only be run once by an application the first time it was started after it
        // deployed the first time. Any updates to the chaincode deployed later would likely not need to run
        // an "init" type function.
        console.log('\n--> Evaluate Transaction: getStudent, function returns an asset with a given studentID');
		let result = await contract.evaluateTransaction('QueryStudent', studentId);
        console.log(`*** Result: ${prettyJSONString(result.toString())}`);
        res.send(prettyJSONString(result.toString()));

    }
    catch(error){
        console.error("Error in getStudent - "+error);
        throw new Error(error);
    }
    finally {
        // Disconnect from the gateway when the application is closing
        // This will close all connections to the network
        gateway.disconnect();
    }
}

async function getCertificate(res,user,studentId,certificateId) {
    const gateway = new Gateway();
    try{
        await gateway.connect(ccp, {
            wallet,
            identity: user,
            discovery: {enabled: true, asLocalhost: true} // using asLocalhost as this gateway is using a fabric network deployed locally
        });

        // Build a network instance based on the channel where the smart contract is deployed
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);

        // Initialize a set of asset data on the channel using the chaincode 'InitLedger' function.
        // This type of transaction would only be run once by an application the first time it was started after it
        // deployed the first time. Any updates to the chaincode deployed later would likely not need to run
        // an "init" type function.
        console.log('\n--> Evaluate Transaction: getCertificate');
		let result = await contract.evaluateTransaction('QueryCertificate', studentId, certificateId);
        console.log(`*** Result: ${prettyJSONString(result.toString())}`);
        res.send(prettyJSONString(result.toString()));

    }
    catch(error){
        console.error("Error in getCertificate - "+error);
        throw new Error(error);
    }
    finally {
        // Disconnect from the gateway when the application is closing
        // This will close all connections to the network
        gateway.disconnect();
    }
}

async function initLedgerFunc(res,user){
    const gateway = new Gateway();
    try{
        await gateway.connect(ccp, {
            wallet,
            identity: user,
            discovery: {enabled: true, asLocalhost: true} // using asLocalhost as this gateway is using a fabric network deployed locally
        });

        // Build a network instance based on the channel where the smart contract is deployed
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);

        // Initialize a set of asset data on the channel using the chaincode 'InitLedger' function.
        // This type of transaction would only be run once by an application the first time it was started after it
        // deployed the first time. Any updates to the chaincode deployed later would likely not need to run
        // an "init" type function.
        console.log('\n--> Submit Transaction: InitLedger, function creates the initial set of assets on the ledger');
        await contract.submitTransaction('InitLedger');
        console.log('*** Result: committed');
        res.send("initLedgerFunc success");
    }
    catch(error){
        console.error("Error in initLedgerFunc - "+error);
        throw new Error(error);
    }
    finally {
        // Disconnect from the gateway when the application is closing
        // This will close all connections to the network
        gateway.disconnect();
    }
}

async function addStudent(res,user,name,email,phone){
    const gateway = new Gateway();
    try{
        await gateway.connect(ccp, {
            wallet,
            identity: user,
            discovery: {enabled: true, asLocalhost: true} // using asLocalhost as this gateway is using a fabric network deployed locally
        });

        // Build a network instance based on the channel where the smart contract is deployed
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);

        // Initialize a set of asset data on the channel using the chaincode 'InitLedger' function.
        // This type of transaction would only be run once by an application the first time it was started after it
        // deployed the first time. Any updates to the chaincode deployed later would likely not need to run
        // an "init" type function.
        console.log('\n--> Submit Transaction: InitLedger, function creates the initial set of assets on the ledger');
        var txnResponse = await contract.submitTransaction('CreateStudent',name,email,phone);
        console.log('*** Result: committed');
        console.log("Response: "+txnResponse);
        res.send('Student Created.');

    }
    catch(error){
        console.error("Error in initLedgerFunc - "+error);
        throw new Error(error);
        
    }
    finally {
        // Disconnect from the gateway when the application is closing
        // This will close all connections to the network
        gateway.disconnect();
    }
}

async function addCertificate(res,user,studentId,university,college,course,issueDate){
    const gateway = new Gateway();
    try{
        await gateway.connect(ccp, {
            wallet,
            identity: user,
            discovery: {enabled: true, asLocalhost: true} // using asLocalhost as this gateway is using a fabric network deployed locally
        });

        // Build a network instance based on the channel where the smart contract is deployed
        const network = await gateway.getNetwork(channelName);

        // Get the contract from the network.
        const contract = network.getContract(chaincodeName);

        // Initialize a set of asset data on the channel using the chaincode 'InitLedger' function.
        // This type of transaction would only be run once by an application the first time it was started after it
        // deployed the first time. Any updates to the chaincode deployed later would likely not need to run
        // an "init" type function.
        console.log('\n--> Submit Transaction: CreateCertificate');
        var txnResponse = await contract.submitTransaction('CreateCertificate',studentId,university,college,course,issueDate);
        console.log('*** Result: committed');
        console.log("Response: "+txnResponse);
        res.send('Certificate Created.');

    }
    catch(error){
        console.error("Error in initLedgerFunc - "+error);
        throw new Error(error);
        
    }
    finally {
        // Disconnect from the gateway when the application is closing
        // This will close all connections to the network
        gateway.disconnect();
    }
}

function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}

app.get('/', (req, res) => {
    res.send('Home Page')
})

app.get('/puc', (req, res) => {
    //
    initializeApp(res,'puc');
})

app.get('/eng', (req, res) => {
    initializeApp(res,'eng');
})

app.get('/training', (req, res) => {
    initializeApp(res,'training');
})

app.get('/company', (req, res) => {
    initializeApp(res,'company');
})

app.post('/puc/init-ledger', (req, res) => {
    //
    var userId = req.body.userId;
    initLedgerFunc(res,userId);
})

app.post('/enroll-admin', (req, res) => {
    //
    enrollAdminFunc(res);
})

app.post('/register-user', (req, res) => {
    //
    var userId = req.body.userId;
    var department = req.body.department;
    console.log();
    registerUserFunc(res,userId,department);
})

app.post('/puc/add-student', (req, res) => {
    //
    var userId = req.body.userId;
    var name = req.body.name;
    var email = req.body.email;
    var phone = req.body.phone;
    addStudent(res,userId,name,email,phone);
})

app.get('/puc/get-student/:id/:user', (req, res) => {
    var studentId = req.params.id;
    var userId = req.params.user;
    console.log("Student ID:"+studentId);
    getStudent(res,userId,studentId);
})

app.post('/add-certificate', (req, res) => {
    //
    var userId = req.body.userId;
    var studentId = req.body.studentId;
    var university = req.body.university;
    var college = req.body.college;
    var course = req.body.course;
    var issueDate = req.body.issueDate;
    addCertificate(res,userId,studentId,university,college,course,issueDate)
    
})

app.get('/get-certificate/:studentid/:certificateid/:user', (req, res) => {
    console.log(req.params);
    var studentId = req.params.studentid;
    var certificateId = req.params.certificateid;
    var userId = req.params.user;
    //console.log("Student ID:"+studentId);
    getCertificate(res,userId,studentId,certificateId);
})



app.get('/init', (req, res) => {
    initializeApp();
    res.send('Init')
})

app.get('/init-ledger', (req, res) => {
    initLedgerFunc();
    res.send('Init Ledger')
})

app.get('/addstudent', (req, res) => {
    addStudent();
    res.send('Init Ledger')
})



app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`);
})
