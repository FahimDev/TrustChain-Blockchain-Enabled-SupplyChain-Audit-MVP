/*
 * SPDX-License-Identifier: Apache-2.0
 */

import { Context, Contract } from 'fabric-contract-api';
import { Product } from './product';
import { v4 as uuidv4 } from 'uuid';

export class TrustChain extends Contract {

    public async initLedger() {
        console.info('============= Ledger Initialized ===========');
    }

    public async queryProduct(ctx: Context, productNumber: string): Promise<string> {
        const productAsBytes = await ctx.stub.getState(productNumber); // get the product from chaincode state
        if (!productAsBytes || productAsBytes.length === 0) {
            throw new Error(`${productNumber} does not exist`);
        }
        console.log(productAsBytes.toString());
        return productAsBytes.toString();
    }

    public async createProduct(ctx: Context, product: Product) {
        console.info('============= START : Create Product ===========');

        const productNumber = "PRODUCT-" + uuidv4();
        await ctx.stub.putState(productNumber, Buffer.from(product));

        console.info('============= END : Create Product ===========');
    }

    public async queryAllProducts(ctx: Context): Promise<string> {
        const startKey = '';
        const endKey = '';
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: key, Record: record });
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }
}
