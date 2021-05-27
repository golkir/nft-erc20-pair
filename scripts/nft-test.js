const hre = require('hardhat')
const { ethers, upgrades } = require("hardhat");
require('dotenv').config()
const contract_addresses = require('../../bsc-contract-addresses.js')

const nftime_address = contract_addresses.test.nftime

async function mintNFT() {
	console.log('here')
	const nftime = await ethers.getContractAt('NFTIME', contract_addresses.test.nftime)
	const minted = await nftime.mint(owner, {gasLimit:4000000,gasPrice:30000000000} )
	
}

async function createPair () {
	const factory = await ethers.getContractAt('NAFTAFactory', contract_addresses.test.factory)

	const nafta_nftime = await factory.naftaPair('NFTIME', nftime_address, 721,{gasLimit:4000000,gasPrice:30000000000})

}


async function getPairInfo() {
	const pair = await ethers.getContractAt('NAFTAPair', contract_addresses.test.factory)
	const info = await pair.getPairInfo()
	console.log(info)
}






