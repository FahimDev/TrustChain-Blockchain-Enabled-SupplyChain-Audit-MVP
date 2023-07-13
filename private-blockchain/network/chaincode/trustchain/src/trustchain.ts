import { Context, Contract } from 'fabric-contract-api';
import { Product } from './product';
import { Inventory } from './inventory';

export class TrustChain extends Contract {

    public async initLedger() {
        console.info('============= Ledger Initialized ===========');
    }

    public async queryState(ctx: Context, key: string): Promise<string> {
        const stateAsBytes = await ctx.stub.getState(key); // get the state from chaincode state
        if (!stateAsBytes || stateAsBytes.length === 0) {
            throw new Error(`${key} does not exist`);
        }
        console.log(stateAsBytes.toString());
        return stateAsBytes.toString();
    }
    
    public async queryAllCollectionWise(ctx: Context, collection: string): Promise<string> {
        const startKey = '';
        const endKey = '';
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange(startKey, endKey)) {
            let match = key.includes(collection);
            if (match) {
                let record;
                const strValue = Buffer.from(value).toString('utf8');

                try {
                    record = JSON.parse(strValue);
                } catch (err) {
                    console.log(err);
                    record = strValue;
                }
              
                allResults.push({ Key: key, Record: record });
            }
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

    public async createProduct(ctx: Context, key: string, product: Product) {
        console.info('============= START : Create Product ===========');

        await ctx.stub.putState(`PROD-${key}`, Buffer.from(product));

        console.info('============= END : Create Product ===========');
    }

    public async createInventory(ctx: Context, key: string, inventory: Inventory) {
        console.info('============= START : Create Product ===========');

        await ctx.stub.putState(`INV-${key}`, Buffer.from(inventory));

        console.info('============= END : Create Product ===========');
    }
}
