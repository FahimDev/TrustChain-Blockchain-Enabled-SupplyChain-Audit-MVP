// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ProductTwin is ERC721URIStorage {

    constructor() public ERC721("TrustChain-BS23", "TC-BS23") {}

    function createTwin(uint256 mfgID, address owner, string memory tokenURI) public returns (uint256) 
    {
        _safeMint(owner, mfgID);  
        _setTokenURI(mfgID, tokenURI);

        return mfgID;
    }
}

