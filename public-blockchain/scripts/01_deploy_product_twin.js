/**
 * In our hardhat.config.js file we have mentioned
 * one of our networks attribute name as `ganache`.
 * That is why we are using that attribute name in our following
 * command: npx hardhat run ./scripts/01_deploy_product_twin.js --network ganache
 * command: npx hardhat run ./scripts/01_deploy_product_twin.js --network goerli
 * verify command: npx hardhat verify --network goerli 0xDeployedContractAddress
 * But we can use multiple network attributes to deploy in different networks also.
 */

const { contractAddressSaver } = require("./track_data_saver")

const { ethers } = require("hardhat");

async function main() {
  // Ref: https://docs.openzeppelin.com/learn/deploying-and-interacting
  const NFTMintContract = await ethers.getContractFactory("ProductTwin");

  // Hardhat doesn’t keep track of your deployed contracts.
  // We displayed the deployed address in our script
  // const genesisContract = await GenesisContract.deploy();
  const productNFTMintContract = await NFTMintContract.deploy();

  console.log("Copy Content Address: ", productNFTMintContract.address);
  await contractAddressSaver("DigitalTwinContract", productNFTMintContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
