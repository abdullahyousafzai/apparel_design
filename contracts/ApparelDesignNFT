// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ApparelDesignNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    // Base URI for metadata
    string private _baseTokenURI;

    // Mapping from token ID to token edition
    mapping(uint256 => string) private _tokenEditions;

    constructor(string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) {
        _baseTokenURI = baseURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // Mint an NFT with a specific edition
    function mintWithEdition(address to, uint256 tokenId, string memory edition) external onlyOwner {
        _mint(to, tokenId);
        _tokenEditions[tokenId] = edition;
    }

    // Get the edition of a token
    function getTokenEdition(uint256 tokenId) external view returns (string memory) {
        return _tokenEditions[tokenId];
    }
}
