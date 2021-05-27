// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const Factory = await ethers.getContractFactory("NAFTAFactory");
  const factory = await upgrades.deployProxy(Factory, []);
  await factory.deployed();
  console.log("NAFTA Factory deployed to:", factory.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });