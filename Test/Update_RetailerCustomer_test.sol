// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "../contracts/RetailerCustomer.sol";

contract TestRetailerCustomer {
    RetailerCustomer retailerCustomer;

    function beforeAll() public {
        retailerCustomer = new RetailerCustomer();
    }

    function checkCreateProduct() public {
        retailerCustomer.manageProduct("create", 1, "Whole Wheat", "Whole Wheat", "AUS", 10, "Whole Wheat", 100);
        RetailerCustomer.WheatProduct[] memory products = retailerCustomer.viewProduct(1);
        Assert.equal(products[0].productType, 1, "Product type should be 1");
        Assert.equal(products[0].wheatType, "Whole Wheat", "Wheat type should be Whole Wheat");
    }

    function checkUpdateProduct() public {
        retailerCustomer.manageProduct("update", 1, "Refined Wheat", "Refined Wheat", "Refined Wheat", 20, "Refined Wheat", 200);
        RetailerCustomer.WheatProduct[] memory products = retailerCustomer.viewProduct(1);
        Assert.equal(products[0].wheatType, "Refined Wheat", "Wheat type should be Refined Wheat");
        Assert.equal(products[0].brand, "Refined Wheat", "Brand should be Refined Wheat");
    }
}
