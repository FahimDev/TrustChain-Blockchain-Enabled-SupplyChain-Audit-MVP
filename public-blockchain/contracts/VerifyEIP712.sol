// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";


contract VerifyEIP712 is EIP712 {
    using ECDSA for bytes32;

    struct LedgerAccess {
        uint256 bsId;
        bytes signature;
    }

    // EIP712 Domain Separator values
    string private constant SIGNING_DOMAIN = "TrustChain-LedgerAccess";
    string private constant SIGNING_VERSION = "1";
    uint256 private constant CHAIN_ID = 5; // Replace with the appropriate chain ID
    address private VERIFYING_CONTRACT = address(this);

    constructor() EIP712(SIGNING_DOMAIN, SIGNING_VERSION) {}

    function _hash(
        LedgerAccess calldata weightedVector
    ) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("LedgerAccess(uint256 bsId)"),
                        weightedVector.bsId
                    )
                )
            );
    }

    function _verify(
        LedgerAccess calldata weightedVector
    ) internal view returns (address) {
        bytes32 digest = _hash(weightedVector);
        return ECDSA.recover(digest, weightedVector.signature);
    }

    function mySigTest(LedgerAccess calldata weightedVector) public view returns (address) {
        address signer = _verify(weightedVector);
        return signer;
    }

}
