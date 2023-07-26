// npx hardhat run ./scripts/05_get_signer_address.js --network goerli
const fs = require("fs");
const { getDeployedPath } = require("./common/file");
const { getInstance } = require("./common/contract");
const { getWallet } = require("./common/wallet");
const ContractAddress = require("../../json-log/LedgerAccessEIP712Contract.json");
const TestSignV4 = require("../../json-log/TargetSignVerification.json");

async function main() {

  const adminWallet = getWallet();
  const verifyContract = getInstance(
    ContractAddress.LedgerAccessEIP712Contract,
    adminWallet
  );
  
  let signerAddress = await verifyContract.getSigner();
  console.log({ signerAddress });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
