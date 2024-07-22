// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FarmerProcessor.sol";

contract FarmerProcessorDelegate {
    FarmerProcessor public delegate;

    constructor(address _farmerProcessorAddress) {
        delegate = FarmerProcessor(_farmerProcessorAddress);
    }

    // Forwarding functions to the delegate contract

    function createOrder(uint _quantity) public returns (uint) {
        (uint orderId,,,) = delegate.manageOrder("create", 0, _quantity);
        return orderId;
    }

    function cancelOrder(uint _orderId) public returns (uint) {
        (uint orderId,,,) = delegate.manageOrder("cancel", _orderId, 0);
        return orderId;
    }

    function viewOrder(uint _orderId) public returns (uint, uint, string memory, address) {
        (uint orderId, uint quantity, string memory status, address processor) = delegate.manageOrder("view", _orderId, 0);
        return (orderId, quantity, status, processor);
    }

    function createOffer(uint _orderId, string memory _harvestDate, uint _pricePerKilogram, string memory _origin) public returns (uint) {
        (, uint offerId) = delegate.manageOffer("create", 0, _orderId, _harvestDate, _pricePerKilogram, _origin);
        return offerId;
    }

    function cancelOffer(uint _offerId) public returns (uint) {
        (, uint offerId) = delegate.manageOffer("cancel", _offerId, 0, "", 0, "");
        return offerId;
    }

    function viewOffers(uint _orderId) public returns (FarmerProcessor.Offer[] memory) {
        (FarmerProcessor.Offer[] memory offers,) = delegate.manageOffer("view", 0, _orderId, "", 0, "");
        return offers;
    }

    function acceptOffer(uint _orderId, uint _offerId) public returns (uint) {
        return delegate.acceptOffer(_orderId, _offerId);
    }

    function getAllTransactions() public view returns (FarmerProcessor.Transaction[] memory) {
        return delegate.getAllTransactions();
    }
}
