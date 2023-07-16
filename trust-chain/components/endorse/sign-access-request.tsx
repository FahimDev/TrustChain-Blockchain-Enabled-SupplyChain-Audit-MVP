import { faCircleQuestion } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import type { NextPage } from "next";
import styles from "../../styles/AccessRequestForm.module.css";
const ContractAddress = require("../../../json-log/deployedContractAddress.json");

const SignAccessRequestComponent: NextPage = () => {
  const handleFormData = async (e: any) => {
    e.preventDefault();

    const data = new FormData(e.target);

    let applicant_dto: any = {
      name: data.get("applicant"),
      org: data.get("applicant-org"),
      wallet: data.get("applicant-wallet"),
    };
    let endorser_dto: any = {
      name: data.get("endorser"),
      org: data.get("endorser-org"),
      wallet: data.get("endorser-wallet"),
    };
    let nft_dto: any = {
      digital_twin: data.get("nft"),
      contract_address: data.get("contract"),
      network: data.get("network"),
    };
    let data_batch_dto: any = {
      mfg_id: Number(data.get("mfg-id")),
      mfg_lic: data.get("mfg-lic"),
      hlf_pk: data.get("hlf-pk"),
      hlf_url: data.get("hlf-url"),
      access_type: data.get("access-type"),
    };
    let signature_validity_dto: any = {
      from_date: data.get("from"),
      to_date: data.get("to"),
    };
    let payload: any = [
        applicant_dto,
        endorser_dto,
        nft_dto,
        data_batch_dto,
        signature_validity_dto,
    ];
    console.log(payload);
    // EIP-721 Data standard
    let permissionDTO_v4: any = {
      messageDTO: payload,
      types: {
        Ledger_Access: [
          { name: "Applicant", type: "Person[]" },
          { name: "Endorser", type: "Person[]" },
          { name: "Product Digital Identity", type: "NFT[]" },
          { name: "Requested Data Batch For Visibility", type: "Data_Batch[]" },
          { name: "Signature Validity", type: "Validity[]" },
        ],
        Person: [
          { name: "name", type: "string" },
          { name: "org", type: "string" },
          { name: "wallet", type: "string" },
        ],
        NFT: [
          { name: "digital_twin", type: "string" },
          { name: "contract_address", type: "string" },
          { name: "network", type: "string" },
        ],
        Data_Batch: [
          { name: "mfg_id", type: "uint256" },
          { name: "mfg_lic", type: "string" },
          { name: "hlf_pk", type: "string" },
          { name: "hlf_url", type: "string" },
          { name: "access_type", type: "string" },
        ],
        Validity: [
          { name: "from_date", type: "string" },
          { name: "to_date", type: "string" },
        ],
      },
    };
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
                        name="mgf-lic"
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
                    type="date"
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
                    type="date"
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
