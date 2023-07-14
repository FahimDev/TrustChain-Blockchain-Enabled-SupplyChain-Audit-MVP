const { ethers } = require("hardhat");

async function main() {
  const NFT = await ethers.getContractFactory("ProductTwin");
  const URI = "https://www.ctgrentacar.com/page/test/nft/786.json";
  const WALLET_ADDRESS = "0xCB6F2B16a15560197342e6afa6b3A5620884265B";
  const CONTRACT_ADDRESS = "0x1cc4c6dD7A05EadFE91948eA28F9ec41e54Aa159";
  const contract = NFT.attach(CONTRACT_ADDRESS);
  await contract.createTwin(786, WALLET_ADDRESS, URI);
  console.log("NFT minted:", contract);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
