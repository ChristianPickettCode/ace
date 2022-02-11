require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("hardhat-gas-reporter");
require('@openzeppelin/hardhat-upgrades');
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    version: "0.8.4",
    optimizer: {
      enabled: true,
      runs: 10
    }
  },
  networks: {
    ropsten: {
      url: process.env.STAGING_ROPSTEN_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    rinkeby: {
      url: process.env.STAGING_RINKEBY_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
      gasMultiplier: 1.4
    },
    koven: {
      url: process.env.STAGING_KOVEN_INFURA_KEY,
      accounts: [process.env.PRIVATE_KEY],
    }
  },
};
