// npx hardhat run ./scripts/04_verify_sign.js --network goerli
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
  let message = TestSignV4.message;
  let ledgerAccess = {};
  ledgerAccess.applicant = message.applicant;
  ledgerAccess.signature = TestSignV4.signature;
  console.log({ ledgerAccess });
  let tx = await verifyContract.mySigTest(ledgerAccess);
  console.log({ tx });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
