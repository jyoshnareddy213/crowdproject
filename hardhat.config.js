require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require('@nomiclabs/hardhat-etherscan');
module.exports = {
  solidity: "0.8.4",
  paths: {
    contracts: ["C:\\Users\\Jyoshnareddy\\Downloads\\crowdproject\\contract"]
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC,
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: process.env.GAS_PRICE || 20000000000, // Use GAS_PRICE environment variable if set, otherwise fallback to default
      gas: process.env.GAS_LIMIT || 3000000 // Use GAS_LIMIT environment variable if set, otherwise fallback to default
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
