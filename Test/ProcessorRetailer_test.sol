// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "../contracts/ProcessorRetailer.sol";

contract TestProcessorRetailer {
    ProcessorRetailer processorRetailer;
    Oracle oracle;

    function beforeAll() public {
        oracle = new Oracle();
        processorRetailer = new ProcessorRetailer(address(oracle));
        // Providing sample data to the Oracle
        oracle.manageData("provide", address(this), 70, 15, 5);
    }

    function checkCreateOrder() public {
        uint orderId = processorRetailer.createOrder(address(this), 1, 100);
        Assert.equal(orderId, 1, "Initial order id should be 1");
    }

    function checkCreateOffer() public {
        uint[] memory offerIds = new uint[](0);
        uint offerId = processorRetailer.createOffer(10, offerIds, "2023-09-15", "Grade A", "2023-09-14", "Grade AUS", 1);
        Assert.equal(offerId, 1, "Initial offer id should be 1");
    }

    function checkCancelOffer() public {
        uint offerId = processorRetailer.cancelOffer(1);
        Assert.equal(offerId, 1, "Cancelled offer id should be 1");
    }

    function checkViewOffers() public {
        uint[] memory offerIds = new uint[](0);
        processorRetailer.createOffer(10, offerIds, "2023-09-15", "Grade A", "2023-09-14", "Grade AUS", 1);
        ProcessorRetailer.Offer[] memory offers = processorRetailer.viewOffers(1);
        Assert.equal(offers.length, 1, "Active offers length should be 1");
    }
}
