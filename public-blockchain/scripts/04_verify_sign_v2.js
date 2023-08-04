// npx hardhat run ./scripts/04_verify_sign_v2.js --network goerli
const fs = require("fs");
const { getDeployedPath } = require("./common/file");
const { getInstance } = require("./common/contract");
const { getWallet } = require("./common/wallet");
const ContractAddress = require("../../json-log/LedgerAccessEIP712Contract-deployedContractAddress.json");
const TestSignV4 = require("../../json-log/TargetSignVerification.json");

async function main() {

  const r= "0x3e20a505b95aaf362ad9eddc7423eacd4c72064b10dfddac680ca8ed867e8b9e";
  const s= "0x0cd292247b0a459eeb5de230db19476648478d6d1d8af95f1224efb0282997f6";
  const signature= "3e20a505b95aaf362ad9eddc7423eacd4c72064b10dfddac680ca8ed867e8b9e0cd292247b0a459eeb5de230db19476648478d6d1d8af95f1224efb0282997f61c";
  const signedMessage= "0x3e20a505b95aaf362ad9eddc7423eacd4c72064b10dfddac680ca8ed867e8b9e0cd292247b0a459eeb5de230db19476648478d6d1d8af95f1224efb0282997f61c";
  const v= 28;

  let message = TestSignV4.message;
  message.signature = signedMessage

  const adminWallet = getWallet();
  const verifyContract = getInstance(
    ContractAddress.LedgerAccessEIP712Contract,
    adminWallet
  );
  console.log(adminWallet.address);
  console.log(message);
  let response = await verifyContract.recoverAddress(message, r, s, v);
  console.log(response);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
