# Hyperledger FireFly Supernode Setup
**A complete stack for enterprises to build and scale secure  `Web3 applications`**

[![framework]][firefly]
[![stack]][author_profile]
[![contributor]][kaleido]

## A MULTI-PARTY SYSTEM FOR ENTERPRISE DATA FLOWS

For quick run the FireFly Binary file and `evmconnect.yml` file is given in the repository. To know more about the FireFly enviroment setup [Click Here][firefly_install_doc] and after the installation and environment setup hit the given command in your terminal to explore `FireFly CLI`

    ff --help


### Key Points
- Connect FireFly to Public Chain
- Deploy Smart Contracts with FireFly API
- Generate Smart Contract Interface
- Create Custom API according to the Smart Contract Interface
- Create Token Pool with Deployed Smart Contract Address
- Basic Auth in FireFly Endpoints

## Using Hyperledger FireFly to Launch an NFT Collection on Public Chains
Initial command layout:  

Creating a FireFly Stack where Stack technology is defined as `ethereum`, stack name is decleard as `ploygon` and stack member count is `1`. 

```
ff init ethereum polygon 1 \

--multiparty=false \

--ipfs-mode public \

-n remote-rpc \

--remote-node-url "https://polygon-mumbai.g.alchemy.com/v2/PROTECTED" \

--chain-id 80001  \

--connector-config evmconnect.yml \

--node-name "TrustChain-Node" \

--org-name "TrustChain-Org"
```

**Make sure to choose your DB.**

>Hyperledger Fabric by default holds a Crypto Wallet Address. To get the wallet address the command is given below: `ff accounts list project_name | grep address`

If you want to modify the wallet address and its private key find the `stack.json` file. 

This file might be in a hidden directory. So try to find the .firefly directory with the given command:

    ls -a

for me the directory location was liks this

    ~/.firefly/stacks/polygon/stack.json

Open the file and you will find an account key there. update the address and provateKey value and save the `json` file.

## FireFly API Endpoints

### Contract Deployment

#### `POST` : `BASE_URL/contracts/deploy`

Sample Request Body :
```json
{ 
    "contract": "PASTE_BYTECODE_HERE", 
    "definition": PASTE_ABI_HERE, 
    "input": [] 
}
```
Sample Response :
```json
{
    { "contractLocation": { 
        "address": "0xfd403b063ecf959867973a4cf383c48b9a06e19e" 
        } 
    }
}
```
#### `POST` : `BASE_URL/contracts/interfaces/generate`

Sample Request :

```json
{ 
    "input": {"abi": PASTE_ABI_HERE}
}
```
**MAKE SURE YOU COPY THE RESPONSE BECAUSE YOU WILL SEND IT AS A REQUEST IN THE NEXT STEP AS A REQUEST BODY**

> This API Endpoint is basically for generating the Request Body for (POST) `BASE_URL/contracts/interfaces` API

#### `POST` : `BASE_URL/contracts/interfaces`

Here we will paste the response from the `BASE_URL/contracts/interfaces/generate` endpoint.

> Make sure to update these two fields.
> ```json
> {
>   "name": "FILL_IN_A_NAME",
>   "version": "FILL_IN_A_VERSION",
>    ...
> }
> ```


> After generating the Contract Interface with the ABI we will get a Contract Interface ID

### Create Custom API for Smart Contract Public Methods

#### `POST` : `http://127.0.0.1:5000/api/v1/apis?confirm=true`

Sample Request :
```json
{
  "interface": {
    "id": "3d9d4d16-b548-4f5c-957e-db44e75f6354"
  },
  "location": {
    "address": "0x3431d051d29fbe4884c6ebc1105f7bd606f0ccab"
  },
  "name": "CUSTOM_ENDPOINT_NAME"
}
```

Sample Response : 
```json
{
  "id": "bd4be993-c009-4068-bfbc-02eb12f1611c",
  "namespace": "default",
  "interface": {
    "id": "3d9d4d16-b548-4f5c-957e-db44e75f6354"
  },
  "location": {
    "address": "0x3431d051d29fbe4884c6ebc1105f7bd606f0ccab"
  },
  "name": "CUSTOM_ENDPOINT_NAME",
  "urls": {
    "openapi": "http://127.0.0.1:5000/api/v1/namespaces/default/apis/CUSTOM_ENDPOINT_NAME/api/swagger.json",
    "ui": "http://127.0.0.1:5000/api/v1/namespaces/default/apis/CUSTOM_ENDPOINT_NAME/api"
  }
}
```

## Create Token Pool
After using the following API endpoints FireFly will start Tracking the Transactions of these Smart Contracts in its Token Pools.

#### `POST` : `BASE_URL/tokens/pools`

Sample Request: 
```json
{
  "config": {
    "address": "YOUR_DEPLOYED_CONTRACT_ADDRESS",
    "blockNumber": "YOUR_CONTRACT_DEPLOYMENT_BLOCK_NUMBER"
  },
  "interface": {
    "id": "YOUR_INTERFACE_ID"
  },
  "name": "YOUR_TOKEN_NAME",
  "symbol": "YOUR_TOKEN_SYMBOL",
  "type": "nonfungible"
}
```

> Even if you are not using FireFly Smart Contract Deployment API you can just generate and register your Smart Contract Interfaces and use this Token Pool API endpoint to track your Smart Contract's Transactions with FireFly. Make sure you have provided the correct Samret Contract Address, Block Number and proper FireFly Interface ID.   


## Mint Token with Default FireFly API

#### `POST` : `BASE_URL/tokens/mint`

#### `POST` : `BASE_URL/tokens/transfers`

> Note that this API is only functional when you are using the OpenZeppelin's Contracts Wizard structured Smart Contract. For calling your Custom Smart Contract's methods with FireFly API use `http://127.0.0.1:5000/api/v1/apis?confirm=true` endpoint.



## Basic Auth in FireFly Endpoints
[Click Here for reference][basic_auth_ref]

First make sure you have `apache2-utils` installed in your system.
    
    sudo apt-get update
    sudo apt-get install apache2-utils

Now create a File with the following command

    touch <file_name>


With the help of `apache2-utils` now you can create a user name and password

    htpasswd -B <file_name> <username>
    htpasswd -B <file_name> <password>

Open the `firefly_core_0.yml` file with an Editor

    nano ~/.firefly/stacks/<stack_name>/runtime/config/firefly_core_0.yml

And add this piece of code in that file:

```
plugins:
  auth:
  - name: test_user_auth
    type: basic
    basic:
      passwordfile: /etc/firefly/<file_name>
```
and under the `namespaces` tag add the `test_user_auth`

```
namespaces:
  predefined:
  - plugins:
    - database0
    - blockchain0
    - dataexchange0
    - sharedstorage0
    - erc20_erc721
    - test_user_auth
```
Now we have to mount the Docker Container with the password hash file:

    nano ~/.firefly/stacks/<stack_name>/docker-compose.override.yml

Open the file with any Editor and mount the password hash file:
```
version: "2.1"
services:
  firefly_core_0:
      volumes:
        - PATH_TO_YOUR_TEST_USERS_FILE:/etc/firefly/test_users
```

> Make sure to restart your FireFly Stack: \
> ff stop <stack_name> \
> ff start <stack_name> 

### Create Token and Modify Request Header

Here I am sharing a python souce code where we are generating a Basic Auth token with the help of username and password.

```python
from base64 import b64encode
def basic_auth(username, password):
    token = b64encode(f"{username}:{password}".encode('utf-8')).decode("ascii")
    print(token)
    
basic_auth('admin', 'admin')
```
> Here our username and password both are same.

**Output:** `YWRtaW46YWRtaW4=`


>**Sample Structure of Request Header:**
>| Key | Value |
>| ------- | --- |
>| Authorization | Basic YWRtaW46YWRtaW4= |

By this way if we add the Authorization key and value in our Request Body we can request to all the API endpoints and also can visit the FireFly-UI landing Page.

> If you want to test the Authorization directly from the linux terminal, try with this given command:
>      `curl -u "firefly:firefly" http://localhost:5000/api/v1/status`  


[framework]: https://img.shields.io/badge/Supernode-FireFly%20-orange
[stack]: https://img.shields.io/badge/Stack-Go%20-blue
[contributor]: https://img.shields.io/badge/Contributor-Kaleido%20-purple
[author_profile]: https://www.linkedin.com/in/engr-arif/
[firefly]: https://www.hyperledger.org/projects/firefly
[kaleido]: https://www.kaleido.io/
[basic_auth_ref]: https://hyperledger.github.io/firefly/tutorials/basic_auth.html
[firefly_install_doc]: https://hyperledger.github.io/firefly/gettingstarted/firefly_cli.html#extract-the-binary-and-move-it-to-usrbinlocal