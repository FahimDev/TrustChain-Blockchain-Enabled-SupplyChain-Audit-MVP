// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

// https://medium.com/coinmonks/convert-solidity-code-to-uml-flow-diagrams-3a5cd412177
// Important: https://gist.github.com/markodayan/e05f524b915f129c4f8500df816a369b
// https://medium.com/metamask/eip712-is-coming-what-to-expect-and-how-to-use-it-bb92fd1a7a26
contract VerifyEIP712 {
    
    struct Person {
        string Name;
        string Organization;
    }

    bytes32 constant PERSON_TYPEHASH = keccak256(abi.encodePacked("Person(string Name,string Organization)"));

    struct LedgerAccess {
        Person applicant;
        bytes signature;
    }

    bytes32 constant LEDGER_ACCESS_TYPEHASH =keccak256(abi.encodePacked("LedgerAccess(Person applicant)Person(string Name,string Organization)"));


    // EIP712 Domain Separator values
    string private constant SIGNING_DOMAIN = "TrustChain-LedgerAccess";
    string private constant SIGNING_VERSION = "1";
    uint256 private constant CHAIN_ID = 5; // Replace with the appropriate chain ID
    address private VERIFYING_CONTRACT = address(this);

 // https://github.com/godappslab/signature-verification/blob/master/contracts/TokenExchangeVerification.sol
    bytes32 constant EIP712DOMAIN_TYPEHASH =keccak256(abi.encodePacked("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"));

    bytes32 private DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(SIGNING_DOMAIN)),
                keccak256(bytes(SIGNING_VERSION)),
                CHAIN_ID,
                VERIFYING_CONTRACT
            )
        );

    function hashPerson(Person memory person) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(bytes(person.Name)),
                    keccak256(bytes(person.Organization))
                )
            );
    }

    function hashLedgerAccess(LedgerAccess memory ledgerAccess) private view returns (bytes32){
        return keccak256(abi.encodePacked(
            "\\x19\\x01",
        DOMAIN_SEPARATOR,
        keccak256(abi.encode(
                LEDGER_ACCESS_TYPEHASH,
                hashPerson(ledgerAccess.applicant)
            ))
        ));
    }

    function recoverAddress(LedgerAccess memory ledgerAccess, bytes32 sigR, bytes32 sigS, uint8 sigV) public view returns (address) {
        return ecrecover(hashLedgerAccess(ledgerAccess), sigV, sigR, sigS);
    }
}
