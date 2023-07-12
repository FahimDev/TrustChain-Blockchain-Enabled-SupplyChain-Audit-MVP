/** @type import('hardhat/config').HardhatUserConfig */

require("@nomiclabs/hardhat-waffle");
require("dotenv").config();


module.exports = {
  solidity: "0.8.18",
  networks: {
    // Ref: https://trufflesuite.com/docs/truffle/getting-started/using-the-truffle-dashboard/#usage-with-non-truffle-tooling
    ganache: {
      /**
       * If you are running your Hardhat at WSL2 make sure you have change
       * your SERVER settings from your Ganache GUI (Windows environment).
       *
       * Change the HOSTNAME to `172.25.224.1 - vEthiernet(WSL)` and Restart Ganache
       */
      url: `${process.env.GANACHE_URL}:${process.env.GANACHE_PORT}`,
      accounts: [`0x${process.env.GANACHE_PRIVATE_KEY}`],
    },    
  },
    // Ref: https://hardhat.org/tutorial/deploying-to-a-live-network
    goerli: {
      url: `${process.env.GOERLI_ENDPOINT}/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`0x${process.env.WALLET_PRIVATE_KEY}`],
    },
};
