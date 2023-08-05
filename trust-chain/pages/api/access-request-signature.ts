import type { NextApiRequest, NextApiResponse } from "next";
import {
  SignTypedDataVersion,
  recoverTypedSignature,
} from "@metamask/eth-sig-util";
import { ethers } from "ethers";
import fs from "fs"; // JSON FILE SAVING

/**
 * @swagger
 * /api/access-request-signature:
 *   post:
 *     tags: [Ledger Access Request | EIP-712]
 *     description: Returns  Sign Data Object
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/definitions/LedgerAccessEnvelope'     # <----------
 *     responses:
 *       200:
 *         description: Sign Data Verification
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               $ref: '#/components/schemas/ReturnEnvelope'
 *
 * definitions:
 *   LedgerAccessEnvelope:           # <----------
 *     type: object
 *     required:
 *       - address
 *     properties:
 *       dto:
 *         type: object
 *       signature:
 *         type: string
 *       address:
 *         type: string
 *
 * components:
 *  schemas:
 *    ReturnEnvelope:
 *      type: object
 *      properties:
 *        id:
 *          type: string
 *          format: uuid
 *        dto:
 *          type: string
 *        signature:
 *          type: string
 *        splitSignature:
 *          type: string
 *        address:
 *          type: string
 *        recordCreatedAt:
 *          type: string
 *          format: date-time
 */

type Data = {
  id: string;
  address: string;
  signedData: string;
  splitSignature: string;
  message: string;
  recordCreatedAt: string;
};

export default async function createMNO(
  req: NextApiRequest,
  res: NextApiResponse<Data>
) {
  console.log(req);
  if (!req.body) {
    res.statusCode = 404;
    res.end("Error");
    return;
  }
  const { dto, signature, address } = req.body;
  try {
    /***********************************|
   |        Sign Typed Data v4          |
   |__________________________________*/

    // The signature is now comprised of r, s, and v.z
    const tempSign = signature.substring(2);
    const r = "0x" + signature.substring(0, 64);
    const s = "0x" + signature.substring(64, 128);
    const v = parseInt(signature.substring(128, 130), 16);
    // Solution Ref: https://github.com/ethers-io/ethers.js/issues/2595

    let restoredAddress = recoverTypedSignature({
      signature,
      version: SignTypedDataVersion.V4,
      data: dto as any,
    });

    if (restoredAddress.toLowerCase() !== address.toLowerCase()) {
      res.statusCode = 401;
      res.end("Invalid");
      // Even if the sign is invalid at MetaMask's Default Method we will store the signature for further investigation.
      signV4Saver(address, { signature: signature, message: dto.message });
      return;
    }

    // Even if the sign is invalid at MetaMask's Default Method we will store the signature for further investigation.
    signV4Saver(address, { signature: signature, message: dto.message, split: { r, s, v } });

    const nowDate: Date = new Date();
    const date_time = nowDate.toISOString().replace(/[:.]/g, ''); // Removes colons and dots

    res.status(200).json({
      id: `${address}-${date_time}-signTypeDataV4`,
      address: address,
      signedData: signature,
      splitSignature: JSON.stringify({ r, s, v }),
      message: JSON.stringify(dto),
      recordCreatedAt: date_time,
    });
  } catch (err) {
    res.statusCode = 400;
    res.end(err);
    return;
  }
}

const signV4Saver = async (signerAddress: string, signTypeV4Payload: any) => {
  // json data
  let jsonData = {
    signerAddress: signerAddress,
    signature: signTypeV4Payload.signature,
    message: signTypeV4Payload.message,
    split: signTypeV4Payload.split,
  };
  let jsonDataStr = JSON.stringify(jsonData);
  const nowDate: Date = new Date();
  const fileName = nowDate.toISOString().replace(/[:.]/g, ''); // Removes colons and dots
  fs.writeFile(
    `../json-log/${signerAddress}-${fileName}-SignV4.json`,
    jsonDataStr,
    "utf8",
    function (err: any) {
      if (err) {
        console.log("An error occured while writing JSON Object to File.");
        return console.log(err);
      }
      console.log("SignTypeV4 has been saved as JSON file.");
    }
  );
};


