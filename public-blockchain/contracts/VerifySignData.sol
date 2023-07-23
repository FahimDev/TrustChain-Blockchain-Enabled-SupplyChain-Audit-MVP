// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// https://medium.com/coinmonks/convert-solidity-code-to-uml-flow-diagrams-3a5cd412177
// Important: https://gist.github.com/markodayan/e05f524b915f129c4f8500df816a369b
contract VerifySignData is EIP712{
    using ECDSA for bytes32;

    string private constant SIGNING_DOMAIN = "TrustChain-LedgerAccess";

    string private constant SIGNATURE_VERSION = "1";

    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {}

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    address public checkSigner;

    bytes32 constant EIP712DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    struct Person {
        string Name;
        string Organization;
        address Wallet;
    }

    struct NFT {
        string DigitalTwin;
        address Contract;
        string Network;
    }

    struct Data_Batch {
        uint256 MFG_ID;
        string MFG_License;
        string LedgerData_PK;
        string GatewayURL;
        string AccessType;
    }

    struct Validity {
        uint256 StartDate;
        uint256 EndDate;
    }

    struct LedgerAccess {
        Person applicant;
        // Person endorser;
        // NFT NFT;
        // Data_Batch dataBatch;
        // Validity validity;
        bytes signature;
    }

    bytes32 constant PERSON_TYPEHASH = keccak256("Person(string Name,string Organization,address Wallet)");

    bytes32 constant WEIGHTEDVECTOR_TYPEHASH =
        keccak256("LedgerAccess(Person applicant,Person endorser,NFT NFT,Data_Batch dataBatch,Validity validity)");

    function hashPerson(Person calldata person) private pure returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("Person(string Name,string Organization,address Wallet)"),
            person.Name,
            person.Organization,
            person.Wallet
        ));
    }

    function _hash(
        LedgerAccess calldata ledgerAccess
    ) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("LedgerAccess(Person applicant,Person endorser)Person(string Name,string Organization,address Wallet)"),
                        hashPerson(ledgerAccess.applicant)
                    )
                )
            );
    }

    function _verify(
        LedgerAccess calldata ledgerAccess
    ) internal view returns (address) {
        bytes32 digest = _hash(ledgerAccess);
        return ECDSA.recover(digest, ledgerAccess.signature);
    }

    function mySigTest(LedgerAccess calldata ledgerAccess) public {
        // make sure signature is valid and get the address of the signer
        // address signer = _verify(voucher);
        address signer = _verify(ledgerAccess);
        checkSigner = signer;
    }

    function resetSigner() public {
        checkSigner = address(0x0);
    }

    function getSigner() public view returns (address) {
        return checkSigner;
    }

}
