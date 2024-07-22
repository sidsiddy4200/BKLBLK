// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RetailerCustomer.sol";

contract RetailerCustomerDelegate {
    RetailerCustomer public delegate;

    constructor(address _retailerCustomerAddress) {
        delegate = RetailerCustomer(_retailerCustomerAddress);
    }

    function manageProduct(
        string memory action,
        uint _productType, 
        string memory _wheatType, 
        string memory _brand, 
        string memory _origin, 
        uint _price, 
        string memory _description, 
        uint _stock
    ) public {
        delegate.manageProduct(action, _productType, _wheatType, _brand, _origin, _price, _description, _stock);
    }

    function manageTransaction(
        string memory action,
        uint _productType,
        uint _quantity,
        uint _transactionId,
        uint[] memory _offerIds
    ) public {
        delegate.manageTransaction(action, _productType, _quantity, _transactionId, _offerIds);
    }

    function viewProduct(uint _productType) public view returns (RetailerCustomer.WheatProduct[] memory) {
        return delegate.viewProduct(_productType);
    }

    function viewTransactions() public view returns (RetailerCustomer.Transaction[] memory) {
        return delegate.viewTransactions();
    }
}
