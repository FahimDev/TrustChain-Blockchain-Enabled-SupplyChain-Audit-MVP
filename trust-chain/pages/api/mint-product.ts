// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from "next";
const artifacts = require("../../../public-blockchain/artifacts/contracts/ProductTwin.sol/ProductTwin.json");
require("dotenv").config();
import { ethers } from "ethers";
import fs from "fs"; // JSON FILE SAVING

// Get Alchemy API Key
const API_KEY = process.env.API_KEY;

// Define an Alchemy Provider
// const provider = new ethers.providers.AlchemyProvider("mumbai", API_KEY);
const provider = new ethers.providers.JsonRpcProvider(`${process.env.API_URL}/${process.env.API_KEY}`)

// Create a signer
const privateKey: any = process.env.WALLET_PRIVATE_KEY;
const signer = new ethers.Wallet(privateKey, provider);

// Get contract ABI and address
const abi = artifacts.abi;
const contractAddress: any = process.env.CONTRACT_ADDRESS;

// Create a contract instance
//const myNftContract = new ethers.Contract(contractAddress, abi, signer);


const myNftContract = new ethers.Contract(contractAddress, abi, provider)

type Data = {
  hash: string;
};

/**
 * @swagger
 * /api/mint-product:
 *   post:
 *     tags: [Mint Digital Twin NFT]
 *     description: Requires NFT-ID, Owner Address, MetaData URL and Returns  Transaction Hash
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/definitions/MintNFTEnvelope'     # <----------
 *     responses:
 *       200:
 *         description: Returns  Transaction Hash
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               $ref: '#/components/schemas/MintedNFT'
 * definitions:
 *   MintNFTEnvelope:           # <----------
 *     type: object
 *     required:
 *       - mfg_id
 *       - ownder
 *       - meta_url
 *     properties:
 *       mfg_id:
 *         type: integer
 *       owner:
 *         type: string
 *       meta_url:
 *         type: string
 *
 * components:
 *  schemas:
 *    MintedNFT:
 *      type: object
 *      properties:
 *        hash:
 *          type: string
 */

export default async function mintProductTwin(
  req: NextApiRequest,
  res: NextApiResponse<Data>
) {
  if (!req.body) {
    res.statusCode = 404;
    res.end("Error");
    return;
  }
  const { mfg_id, owner, meta_url } = req.body;
  try {
    console.log(mfg_id)
    console.log(owner)
    console.log(meta_url)
    let sample: number = parseInt(mfg_id)
    console.log("=====>", sample)
    let nftTxn = await myNftContract.createTwin(sample, owner, meta_url);
    console.log("FLAG!")
    await nftTxn.wait();
    console.log(nftTxn)
    console.log(
      `NFT Minted! Check it out at: ${process.env.POLYGONSCAN_MUMBAI}/${nftTxn.hash}`
    );
    // signV4Saver(
    //   mfg_id,
    //   nftTxn.hash,
    //   `${process.env.POLYGONSCAN_MUMBAI}/${nftTxn.hash}`
    // );
    res.status(200).json({ hash: nftTxn.hash });
  } catch (err) {
    res.statusCode = 400;
    res.end(err);
    return;
  }
}

// const signV4Saver = async (nft_id: bigint, tx_hash: string, tx_url: string) => {
//   // json data
//   let jsonData = {
//     nft_id: nft_id,
//     tx_hash: tx_hash,
//     transaction_url: tx_url,
//   };
//   let jsonDataStr = JSON.stringify(jsonData);
//   fs.writeFile(
//     `../../../json-log/nft-${nft_id}-mint-txn.json`,
//     jsonDataStr,
//     "utf8",
//     function (err: any) {
//       if (err) {
//         console.log("An error occured while writing JSON Object to File.");
//         return console.log(err);
//       }
//       console.log("NFT Minting Transaction has been saved as JSON file.");
//     }
//   );
// };
