import { faCircleQuestion } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import type { NextPage } from "next";
import { ethers } from "ethers";
import { useEffect, useRef, useState } from "react";
import { useWeb3React } from "@web3-react/core";
import styles from "../../styles/AccessRequestForm.module.css";
const ContractAddress = require("../../../json-log/deployedContractAddress.json");

const SignAccessRequestComponent: NextPage = () => {
  /**
   * In useState first element can be an object and
   * the second elementr is a value setter function of that object
   *  */
  const [signatures, setSignaturesFun] = useState<any>([]);
  const { active, library: provider } = useWeb3React();
  const delay = (ms: number | undefined) =>
    new Promise((res) => setTimeout(res, ms));

  const SIGNING_DOMAIN_NAME = "TrustChain-LedgerAccess";
  const SIGNING_DOMAIN_VERSION = "1";
  const SIGNING_DOMAIN_CHAIN_ID = 5;
  const CONTRACT_ADDRESS = "0x1cc4c6dd7a05eadfe91948ea28f9ec41e54aa159";

  // EIP-721 Data standard
  const _domain = {
    name: SIGNING_DOMAIN_NAME,
    version: SIGNING_DOMAIN_VERSION,
    verifyingContract: CONTRACT_ADDRESS,
    chainId: SIGNING_DOMAIN_CHAIN_ID,
  };
  // EIP-721 Data standard
  const _domainDataType = [
    { name: "name", type: "string" },
    { name: "version", type: "string" },
    { name: "verifyingContract", type: "address" },
    { name: "chainId", type: "uint256" },
  ];

  const checkWallet = async () => {
    if (!window.ethereum) {
      throw new Error("No crypto wallet found. Please install it.");
      return null;
    }
    if (!active) {
      window.alert("Your wallet is not connected!");
      return null;
    }
    return "Connected";
  };

  const _signingDomain = (contractAddress: string) => {
    const _domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: contractAddress,
      chainId: SIGNING_DOMAIN_CHAIN_ID,
    };
    return _domain;
  };

  const getSignature = async (domain: any, types: any, voucher: any) => {
    const signer = provider.getSigner();
    const signature = await signer._signTypedData(domain, types, voucher);
    return signature;
  };

  const createWeightedVector = async (
    applicant: any,
    endorser: any,
    NFT: any,
    dataBatch: any,
    validity: any,
    contractAddress: string
  ) => {
    const LedgerAccess: any = {
      applicant,
      endorser,
      NFT,
      dataBatch,
      validity,
    };
    let ledgerAccessVector = JSON.stringify(LedgerAccess)
    const domain = _signingDomain(contractAddress);
    return {
      domain,
      LedgerAccess,
    };
  };

  const signMessageV4 = async (dto: any) => {
    if ((await checkWallet()) == null) {
      return null;
    }
    try {
      let data = dto.messageDTO;

      const msgPayload = {
        domain: _domain,
        message: data,
        primaryType: "LedgerAccess",
        types: {
          EIP712Domain: _domainDataType,
          ...dto.types,
        },
      };

      const signer = provider.getSigner();
      const address = await signer.getAddress();
      // Set up variables for message signing
      // let msgParams = JSON.stringify(msgPayload);
      let obj = await createWeightedVector(
        data.applicant,
        data.endorser,
        data.NFT,
        data.dataBatch,
        data.validity,
        CONTRACT_ADDRESS
      );
      const dataPacket: any = obj.LedgerAccess;
      const domain: any = obj.domain;
      const signature = await getSignature(domain, dto.types, dataPacket);

      // This signGeneratorV4() method is strictly following MetaMask's Sign Type V4 process.
      // const signature: string = await signGeneratorV4(method, params, address);
      return {
        msgPayload,
        signature,
        address,
      };
    } catch (err) {
      console.log(err);
      window.alert(err);
      return null;
    }
  };


  const postAPI = async (sig: any) => {
    /***********************************|
   |        API Integration             |
   |__________________________________*/
    let context: any = {
      dto: sig?.msgPayload,
      signature: sig?.signature,
      address: sig?.address,
    };

    const rawResponse = await fetch("/api/access-request-signature", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(context),
    });
    if (rawResponse.status == 200) {
      window.alert(
        "Sign Type V4 Verified by MetaMask Method (js) ! Sign saved as JSON File for R&D."
      );
    } else if (rawResponse.status == 404) {
      window.alert("Sign Type V4 is Invalid!");
    } else if (rawResponse.status == 401) {
      window.alert("Signature Invalid. Singer Address can not recover!");
    } else {
      window.alert(
        "Something went wrong in Sign Type V4 Verification Error Unknown!"
      );
    }
  };

  const handleFormData = async (e: any) => {
    e.preventDefault();

    const data = new FormData(e.target);
    // Convert to Unix timestamp
    let valid_from = Math.floor(new Date(data.get("from")).getTime() / 1000);
    let valid_to = Math.floor(new Date(data.get("to")).getTime() / 1000);

    let applicant_dto: any = {
      Name: data.get("applicant"),
      Organization: data.get("applicant-org"),
      Wallet: data.get("applicant-wallet"),
    };
    let endorser_dto: any = {
      Name: data.get("endorser"),
      Organization: data.get("endorser-org"),
      Wallet: data.get("endorser-wallet"),
    };
    let nft_dto: any = {
      DigitalTwin: data.get("nft"),
      Contract: data.get("contract"),
      Network: data.get("network"),
    };
    let data_batch_dto: any = {
      MFG_ID: Number(data.get("mfg-id")),
      MFG_License: data.get("mfg-lic"),
      LedgerData_PK: data.get("hlf-pk"),
      GatewayURL: data.get("hlf-url"),
      AccessType: data.get("access-type"),
    };
    let signature_validity_dto: any = {
      StartDate: valid_from,
      EndDate: valid_to,
    };
    let payload: any = {
      applicant: applicant_dto,
      endorser: endorser_dto,
      NFT: nft_dto,
      dataBatch: data_batch_dto,
      validity: signature_validity_dto,
    };
    // EIP-721 Data standard
    let permissionDTO_v4: any = {
      messageDTO: payload,
      types: {
        LedgerAccess: [
          { name: "applicant", type: "Person" },
          { name: "endorser", type: "Person" },
          { name: "NFT", type: "NFT" },
          { name: "dataBatch", type: "Data_Batch" },
          { name: "validity", type: "Validity" },
        ],
        Person: [
          { name: "Name", type: "string" },
          { name: "Organization", type: "string" },
          { name: "Wallet", type: "address" },
        ],
        NFT: [
          { name: "DigitalTwin", type: "string" },
          { name: "Contract", type: "address" },
          { name: "Network", type: "string" },
        ],
        Data_Batch: [
          { name: "MFG_ID", type: "uint256" },
          { name: "MFG_License", type: "string" },
          { name: "LedgerData_PK", type: "string" },
          { name: "GatewayURL", type: "string" },
          { name: "AccessType", type: "string" },
        ],
        Validity: [
          { name: "StartDate", type: "uint256" },
          { name: "EndDate", type: "uint256" },
        ],
      },
    };

    const signature_obj = await signMessageV4(permissionDTO_v4);

    if (signature_obj && signature_obj?.signature.length > 0) {
      /**
       * The use of '...' in the array is to prevent the data override issue in any index
       * It keeps the continuity of the index and assign data and a new empty index.
       *   */
      setSignaturesFun([...signatures, signature_obj]);
      /**
       * ##########--> Optional chaining (?.) <--##########
       * The optional chaining (?.) operator accesses an object's property or calls a function.
       * If the object is undefined or null, it returns undefined instead of throwing an error.
       */
      window.alert(
        `*** SIGNING DATA SUCCESSFUL ***\n ===> Signer Address: ${signature_obj?.address} \n ===> Signed Data: ${signature_obj?.signature}`
      );
      postAPI(signature_obj);
    } else {
      window.alert("Please, check your wallet and try again.");
    }
  };

  return (
    <div className={styles.container}>
      <main className={styles.main}>
        <div className="flex flex-row flex-wrap justify-center">
          <div className="basis-3/6">
            <form
              onSubmit={handleFormData}
              className="shadow-xl border-double border-4 border-cyan-600 rounded-lg border-x-cyan-100"
            >
              <div className="p-8">
                <h1 className="capitalize hover:uppercase text-2xl">
                  Pending Request
                </h1>
                <p className="indent-4">
                  Please review and update the requested data schema and proceed
                  the Signature.{" "}
                  <a
                    href="https://cellidfinder.com/mcc-mnc"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <FontAwesomeIcon icon={faCircleQuestion} />
                  </a>
                </p>
                <hr />

                <div id="applicant">
                  <div className="inline-flex items-center justify-center w-full">
                    <hr className="w-64 h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
                    <span className="absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900">
                      Applicant
                    </span>
                  </div>

                  <div className="flex flex-wrap -mx-3 mb-6">
                    <div className="w-full md:w-1/2 px-3 mb-6 md:mb-0">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        Name
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-red-500 rounded py-3 px-4 mb-3 leading-tight focus:outline-none focus:bg-white"
                        id="applicant"
                        name="applicant"
                        type="text"
                        placeholder="----"
                      />
                    </div>
                    <div className="w-full md:w-1/2 px-3">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        Organization
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-gray-200 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                        id="applicant-org"
                        name="applicant-org"
                        type="text"
                        placeholder="------"
                      />
                    </div>
                  </div>

                  <div>
                    <label>
                      <b>Wallet Address</b>
                    </label>
                    <input
                      type="text"
                      placeholder="0x.........."
                      name="applicant-wallet"
                      id="applicant-wallet"
                      className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                      required
                    />
                  </div>
                  <p className="text-red-500 text-xs italic">
                    Please check and verify the given information.
                  </p>
                </div>

                <div id="endorser">
                  <div className="inline-flex items-center justify-center w-full">
                    <hr className="w-64 h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
                    <span className="absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900">
                      Endorser
                    </span>
                  </div>

                  <div className="flex flex-wrap -mx-3 mb-6">
                    <div className="w-full md:w-1/2 px-3 mb-6 md:mb-0">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        Name
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-red-500 rounded py-3 px-4 mb-3 leading-tight focus:outline-none focus:bg-white"
                        id="endorser"
                        name="endorser"
                        type="text"
                        placeholder="----"
                      />
                    </div>
                    <div className="w-full md:w-1/2 px-3">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        Organization
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-gray-200 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                        id="endorser-org"
                        name="endorser-org"
                        type="text"
                        placeholder="------"
                      />
                    </div>
                  </div>

                  <div>
                    <label>
                      <b>Wallet Address</b>
                    </label>
                    <input
                      type="text"
                      placeholder="0x.........."
                      name="endorser-wallet"
                      id="endorser-wallet"
                      className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                      required
                    />
                  </div>
                  <p className="text-red-500 text-xs italic">
                    Please review the given information carefully.
                  </p>
                </div>

                <div id="digital-twin">
                  <div className="inline-flex items-center justify-center w-full">
                    <hr className="w-64 h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
                    <span className="absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900">
                      Product Digital Identity
                    </span>
                  </div>

                  <div id="nft">
                    <label>
                      <b>Digital Twin URL</b>
                    </label>
                    <input
                      id="nft"
                      name="nft"
                      type="url"
                      placeholder="www.opensea.io"
                      className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                      required
                    />
                  </div>

                  <div>
                    <label>
                      <b>Smart Contract Address</b>
                    </label>
                    <input
                      type="text"
                      placeholder="0x.........."
                      name="contract"
                      id="contract"
                      className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                      required
                    />
                  </div>
                  <div>
                    <label>
                      <b>Network Title</b>
                    </label>
                    <input
                      type="text"
                      placeholder="Goerli"
                      name="network"
                      id="network"
                      className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                      required
                    />
                  </div>
                </div>

                <div id="endorser">
                  <div className="inline-flex items-center justify-center w-full">
                    <hr className="w-64 h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
                    <span className="absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900">
                      Requested Data Batch for Visibility
                    </span>
                  </div>

                  <div className="flex flex-wrap -mx-3 mb-6">
                    <div className="w-full md:w-1/2 px-3 mb-6 md:mb-0">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        MFG. ID
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-red-500 rounded py-3 px-4 mb-3 leading-tight focus:outline-none focus:bg-white"
                        id="mfg-id"
                        name="mfg-id"
                        type="number"
                        placeholder="----"
                      />
                    </div>
                    <div className="w-full md:w-1/2 px-3">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        MFG. License
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-gray-200 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                        id="mfg-lic"
                        name="mfg-lic"
                        type="text"
                        placeholder="------"
                      />
                    </div>
                  </div>

                  <div className="flex flex-wrap -mx-3 mb-6">
                    <div className="w-full md:w-1/2 px-3 mb-6 md:mb-0">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        Private Ledger ID
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-red-500 rounded py-3 px-4 mb-3 leading-tight focus:outline-none focus:bg-white"
                        id="hlf-pk"
                        name="hlf-pk"
                        type="text"
                        placeholder="----"
                      />
                    </div>
                    <div className="w-full md:w-1/2 px-3">
                      <label className="block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2">
                        Access Type
                      </label>
                      <input
                        className="appearance-none block w-full bg-gray-200 text-gray-700 border border-gray-200 rounded py-3 px-4 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
                        id="access-type"
                        name="access-type"
                        type="text"
                        placeholder="READ ONLY"
                      />
                    </div>
                  </div>

                  <div>
                    <label>
                      <b>Gateway URL</b>
                    </label>
                    <input
                      type="url"
                      placeholder="www.web3.example-org.com/private-ledger/pk=sample-id"
                      name="hlf-url"
                      id="hlf-url"
                      className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                      required
                    />
                  </div>
                  <p className="text-red-500 text-xs italic">
                    Make sure you want to give access for this exact Product
                    with this URL End-Point.
                  </p>
                </div>

                <hr />
                <div id="signature-validity">
                  <div className="inline-flex items-center justify-center w-full">
                    <hr className="w-64 h-px my-8 bg-gray-200 border-0 dark:bg-gray-700" />
                    <span className="absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900">
                      Signature Validity
                    </span>
                  </div>

                  <label>
                    <b>
                      Start Date <sub>(Valid From)</sub>
                    </b>
                  </label>
                  <input
                    type="datetime-local"
                    placeholder=""
                    name="from"
                    id="from"
                    className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                    required
                  />
                  <label>
                    <b>
                      {" "}
                      End Date <sub>(Valid till)</sub>
                    </b>
                  </label>
                  <input
                    type="datetime-local"
                    placeholder=""
                    name="to"
                    id="to"
                    className="mt-1 block w-full px-3 py-2 bg-white border border-slate-300 rounded-md text-sm shadow-sm placeholder-slate-400
              focus:outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500
              disabled:bg-slate-50 disabled:text-slate-500 disabled:border-slate-200 disabled:shadow-none
              invalid:border-pink-500 invalid:text-pink-600
              focus:invalid:border-pink-500 focus:invalid:ring-pink-500"
                    required
                  />
                </div>

                <hr />
                <p>
                  By creating an account you agree to our{" "}
                  <a
                    className="no-underline hover:underline decoration-4 decoration-lime-800"
                    href="#"
                  >
                    Terms & Privacy
                  </a>
                  .<br></br>
                  <span className="bg-green-100 text-green-800 text-xs font-medium mr-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300">
                    Verified Smart Contract Address:
                    <span className="inline-flex items-center p-1 mr-2 text-sm font-semibold text-blue-800 bg-blue-100 rounded-full dark:bg-gray-700 dark:text-blue-400">
                      <svg
                        aria-hidden="true"
                        className="w-3 h-3"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          fill-rule="evenodd"
                          d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                          clip-rule="evenodd"
                        ></path>
                      </svg>{" "}
                      <a
                        href={
                          "https://goerli.etherscan.io/address/" +
                          ContractAddress.genesisContract +
                          "#code"
                        }
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        {ContractAddress.genesisContract}{" "}
                      </a>
                      <span className="sr-only">Verified Smart Contract</span>
                    </span>
                  </span>
                </p>
                <div className="flex items-center justify-center p-4">
                  <span className="relative inline-flex">
                    <button
                      type="submit"
                      className={`${styles.registerbtn} inline-flex items-center px-4 py-2 font-semibold leading-6 text-sm shadow rounded-md text-sky-500 bg-white dark:bg-slate-800 transition ease-in-out duration-150 cursor-not-allowed ring-1 ring-slate-900/10 dark:ring-slate-200/20`}
                    >
                      Proceed To Signature Operations
                    </button>
                    <span className="flex absolute h-3 w-3 top-0 right-0 -mt-1 -mr-1">
                      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"></span>
                      <span className="relative inline-flex rounded-full h-3 w-3 bg-sky-500"></span>
                    </span>
                  </span>
                </div>

                <div className={styles.signin}>
                  <p>
                    Want to see other pending requests?{" "}
                    <a
                      className="no-underline hover:underline decoration-4 decoration-sky-500"
                      href="#"
                    >
                      Click Here!
                    </a>
                  </p>
                </div>
              </div>
            </form>
          </div>
        </div>
      </main>
    </div>
  );
};
export default SignAccessRequestComponent;
