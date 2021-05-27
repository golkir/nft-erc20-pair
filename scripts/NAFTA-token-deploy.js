// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const NAFTA = await ethers.getContractFactory("NAFTA");
  const nafta = await NAFTA.deploy();
  console.log("NAFTA token deployed to:", nafta.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });