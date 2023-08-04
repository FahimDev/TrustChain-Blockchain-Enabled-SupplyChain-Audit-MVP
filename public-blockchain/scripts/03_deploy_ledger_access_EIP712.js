/**
 * In our hardhat.config.js file we have mentioned
 * one of our networks attribute name as `ganache`.
 * That is why we are using that attribute name in our following
 * command: npx hardhat run ./scripts/03_deploy_ledger_access_EIP712.js --network ganache
 * command: npx hardhat run ./scripts/03_deploy_ledger_access_EIP712.js --network goerli
 * verify command: npx hardhat verify --network goerli 0xDeployedContractAddress
 * But we can use multiple network attributes to deploy in different networks also.
 */

const { contractAddressSaver } = require("./track_data_saver")

const { ethers } = require("hardhat");

async function main() {

  // Ref: https://docs.openzeppelin.com/learn/deploying-and-interacting
  const SignVerifyContract = await ethers.getContractFactory("VerifyEIP712");

  // Hardhat doesn’t keep track of your deployed contracts.
  // We displayed the deployed address in our script
  // const genesisContract = await GenesisContract.deploy();
  const signVerifyContract = await SignVerifyContract.deploy();

  console.log("Copy Content Address: ", signVerifyContract.address);
  await contractAddressSaver("LedgerAccessEIP712Contract",signVerifyContract.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
