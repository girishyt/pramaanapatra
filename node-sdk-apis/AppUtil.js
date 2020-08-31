/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const fs = require('fs');
const path = require('path');

exports.buildCCP = (org) => {
	// load the common connection configuration file

	var ccpPath;

	if(org==='puc'){
		ccpPath = path.resolve(__dirname, '..', 'test-gt-network', 'organizations', 'peerOrganizations', 'puc.example.com', 'connection-puc.json');
	}

	if(org==='eng'){
		ccpPath = path.resolve(__dirname, '..', 'test-gt-network', 'organizations', 'peerOrganizations', 'eng.example.com', 'connection-eng.json');
	}

	if(org==='training'){
		ccpPath = path.resolve(__dirname, '..', 'test-gt-network', 'organizations', 'peerOrganizations', 'training.example.com', 'connection-training.json');
	}

	if(org==='company'){
		ccpPath = path.resolve(__dirname, '..', 'test-gt-network', 'organizations', 'peerOrganizations', 'company.example.com', 'connection-company.json');
	}
	
	const fileExists = fs.existsSync(ccpPath);
	if (!fileExists) {
		throw new Error(`no such file or directory: ${ccpPath}`);
	}
	const contents = fs.readFileSync(ccpPath, 'utf8');

	// build a JSON object from the file contents
	const ccp = JSON.parse(contents);

	console.log(`Loaded the network configuration located at ${ccpPath}`);
	return ccp;
};

exports.buildWallet = async (Wallets, walletPath) => {
	// Create a new  wallet : Note that wallet is for managing identities.
	let wallet;
	if (walletPath) {
		wallet = await Wallets.newFileSystemWallet(walletPath);
		console.log(`Built a file system wallet at ${walletPath}`);
	} else {
		wallet = await Wallets.newInMemoryWallet();
		console.log('Built an in memory wallet');
	}

	return wallet;
};
