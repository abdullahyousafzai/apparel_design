// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ApparelDesignNFTMarketplace is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private listingIds;

    struct Listing {
        uint256 listingId;
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool isSold;
    }

    mapping(uint256 => Listing) public listings;

    event ListingCreated(uint256 indexed listingId, address indexed seller, address indexed nftContract, uint256 tokenId, uint256 price);
    event ListingSold(uint256 indexed listingId, address indexed buyer, uint256 price);

    function createListing(address _nftContract, uint256 _tokenId, uint256 _price) external {
        require(_price > 0, "Price must be greater than 0");
        require(IERC721(_nftContract).ownerOf(_tokenId) == msg.sender, "You don't own this NFT");

        listingIds.increment();
        uint256 listingId = listingIds.current();

        listings[listingId] = Listing(listingId, msg.sender, _nftContract, _tokenId, _price, false);

        emit ListingCreated(listingId, msg.sender, _nftContract, _tokenId, _price);
    }

    function buyListing(uint256 _listingId) external payable {
        Listing storage listing = listings[_listingId];

        require(!listing.isSold, "Listing is already sold");
        require(msg.value >= listing.price, "Insufficient funds to purchase");

        listing.isSold = true;
        IERC721(listing.nftContract).safeTransferFrom(listing.seller, msg.sender, listing.tokenId);
        payable(listing.seller).transfer(msg.value);

        emit ListingSold(_listingId, msg.sender, listing.price);
    }

    function cancelListing(uint256 _listingId) external {
        Listing storage listing = listings[_listingId];

        require(msg.sender == listing.seller, "You can only cancel your own listings");
        require(!listing.isSold, "Cannot cancel a sold listing");

        delete listings[_listingId];

        emit ListingCreated(_listingId, address(0), address(0), 0, 0);
    }

    function getListing(uint256 _listingId) external view returns (uint256, address, address, uint256, uint256, bool) {
        Listing memory listing = listings[_listingId];
        return (listing.listingId, listing.seller, listing.nftContract, listing.tokenId, listing.price, listing.isSold);
    }
}
