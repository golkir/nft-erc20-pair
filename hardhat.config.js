require('dotenv').config()
require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
const bsc_pkey = process.env.BSC_TEST_PKEY;


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
// task("accounts", "Prints the list of accounts", async () => {
//   const accounts = await ethers.getSigners();

//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "bsctest",
  networks: {
    hardhat: {
    },
    bsctest: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      accounts: [bsc_pkey],
      chainId: 97
    }
  },
  solidity: {
    version: "0.6.2",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};

