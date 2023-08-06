// npx hardhat run ./scripts/04_verify_sign_v2.js --network goerli
const fs = require("fs");
const { getDeployedPath } = require("./common/file");
const { getInstance } = require("./common/contract");
const { getWallet } = require("./common/wallet");
const ContractAddress = require("../../json-log/LedgerAccessEIP712Contract-deployedContractAddress.json");
const TestSignV4 = require("../../json-log/TargetSignVerification.json");

async function main() {

  let message = TestSignV4.message;
  message.signature = TestSignV4.signature;

  const adminWallet = getWallet();
  const verifyContract = getInstance(
    ContractAddress.LedgerAccessEIP712Contract,
    adminWallet
  );
  console.log(adminWallet.address);
  console.log(message);
  let response = await verifyContract.mySigTest(message);
  console.log(response);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
