// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApparelDesignNFT.sol";

contract ApparelDesignSupplyChain {
    address public owner;
    ApparelDesignNFT public nftContract;

    enum DesignStatus { Created, Approved, Produced, Shipped, Received }

    struct Design {
        uint256 designId;
        address designer;
        string name;
        DesignStatus status;
        uint256 tokenId; // Associated NFT token ID
        uint256[] trackingInfo; // Array to store tracking information
    }

    struct Shipment {
        uint256 shipmentId;
        uint256 designId;
        string destination;
        DesignStatus status;
    }

    mapping(uint256 => Design) public designs;
    mapping(uint256 => Shipment) public shipments;
    uint256 public designCounter;
    uint256 public shipmentCounter;

    event DesignCreated(uint256 designId, string name);
    event DesignApproved(uint256 designId);
    event DesignProduced(uint256 designId);
    event DesignShipped(uint256 designId);
    event DesignReceived(uint256 designId);
    event DesignTracked(uint256 designId, string statusUpdate);

    constructor(address _nftContractAddress) {
        owner = msg.sender;
        nftContract = ApparelDesignNFT(_nftContractAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function createDesign(string memory name) public onlyOwner {
        designCounter++;
        uint256 tokenId = nftContract.totalSupply() + 1; // Mint a new NFT for the design
        nftContract.mintWithEdition(msg.sender, tokenId, name); // Mint NFT with designer as owner
        designs[designCounter] = Design(designCounter, msg.sender, name, DesignStatus.Created, tokenId, new uint256[](0));
        emit DesignCreated(designCounter, name);
    }

    function approveDesign(uint256 designId) public onlyOwner {
        require(designs[designId].status == DesignStatus.Created, "Design is not in 'Created' status");
        designs[designId].status = DesignStatus.Approved;
        emit DesignApproved(designId);
    }

    function produceDesign(uint256 designId) public onlyOwner {
        require(designs[designId].status == DesignStatus.Approved, "Design is not in 'Approved' status");
        designs[designId].status = DesignStatus.Produced;
        emit DesignProduced(designId);
    }

    function shipDesign(uint256 designId, string memory destination) public onlyOwner {
        require(designs[designId].status == DesignStatus.Produced, "Design is not in 'Produced' status");
        shipmentCounter++;
        shipments[shipmentCounter] = Shipment(shipmentCounter, designId, destination, DesignStatus.Shipped);
        emit DesignShipped(designId);
    }

    function receiveDesign(uint256 shipmentId, string memory statusUpdate) public onlyOwner {
        require(shipments[shipmentId].status == DesignStatus.Shipped, "Shipment is not in 'Shipped' status");
        uint256 designId = shipments[shipmentId].designId;
        designs[designId].status = DesignStatus.Received;
        designs[designId].trackingInfo.push(block.timestamp); // Record the timestamp of the status update
        emit DesignReceived(designId);
        emit DesignTracked(designId, statusUpdate);
    }

    // Get the tracking information for a design
    function getTrackingInfo(uint256 designId) public view returns (uint256[] memory) {
        return designs[designId].trackingInfo;
    }
}
