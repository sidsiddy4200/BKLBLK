// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FarmerProcessor.sol";
import "./ProcessorRetailer.sol";
import "./RetailerCustomer.sol";

contract Incident {
    FarmerProcessor public farmerProcessor;
    ProcessorRetailer public processorRetailer;
    RetailerCustomer public retailerCustomer;

    constructor(address _farmerProcessorAddress, address _processorRetailerAddress, address _retailerCustomerAddress) {
        farmerProcessor = FarmerProcessor(_farmerProcessorAddress);
        processorRetailer = ProcessorRetailer(_processorRetailerAddress);
        retailerCustomer = RetailerCustomer(_retailerCustomerAddress);
    }

    /**
     * @dev Given a farmer's offer ID, trace all the transaction records in all smart contracts which involve this farmer's offer ID.
     * @param offerId The farmer's offer ID
     * @return A tuple containing: 
     *  - The transaction in FarmerProcessor.sol
     *  - An array of transactions in ProcessorRetailer.sol
     *  - An array of transactions in RetailerCustomer.sol
     */
    function trace(uint offerId) public view returns (
        FarmerProcessor.Transaction memory, 
        ProcessorRetailer.Transaction[] memory, 
        RetailerCustomer.Transaction[] memory
    ) {
        // Get all transactions from each contract
        FarmerProcessor.Transaction[] memory farmerTransactions = farmerProcessor.getAllTransactions();
        ProcessorRetailer.Transaction[] memory processorTransactions = processorRetailer.getAllTransactions();
        RetailerCustomer.Transaction[] memory retailerTransactions = retailerCustomer.getAllTransactions();

        // Initialize placeholders for the result
        FarmerProcessor.Transaction memory farmerTransaction;
        uint processorCounter = 0;
        uint retailerCounter = 0;

        // Count the matches first to avoid resizing arrays later
        for (uint i = 0; i < processorTransactions.length; i++) {
            for (uint j = 0; j < processorTransactions[i].offerIds.length; j++) {
                if (processorTransactions[i].offerIds[j] == offerId) {
                    processorCounter++;
                    break;
                }
            }
        }

        for (uint i = 0; i < retailerTransactions.length; i++) {
            for (uint j = 0; j < retailerTransactions[i].offerIds.length; j++) {
                if (retailerTransactions[i].offerIds[j] == offerId) {
                    retailerCounter++;
                    break;
                }
            }
        }

        ProcessorRetailer.Transaction[] memory matchedProcessorTransactions = new ProcessorRetailer.Transaction[](processorCounter);
        RetailerCustomer.Transaction[] memory matchedRetailerTransactions = new RetailerCustomer.Transaction[](retailerCounter);

        processorCounter = 0;
        retailerCounter = 0;

        // Find the matching transactions
        for (uint i = 0; i < farmerTransactions.length; i++) {
            if (farmerTransactions[i].offerId == offerId) {
                farmerTransaction = farmerTransactions[i];
                break;
            }
        }

        for (uint i = 0; i < processorTransactions.length; i++) {
            for (uint j = 0; j < processorTransactions[i].offerIds.length; j++) {
                if (processorTransactions[i].offerIds[j] == offerId) {
                    matchedProcessorTransactions[processorCounter] = processorTransactions[i];
                    processorCounter++;
                    break;
                }
            }
        }

        for (uint i = 0; i < retailerTransactions.length; i++) {
            for (uint j = 0; j < retailerTransactions[i].offerIds.length; j++) {
                if (retailerTransactions[i].offerIds[j] == offerId) {
                    matchedRetailerTransactions[retailerCounter] = retailerTransactions[i];
                    retailerCounter++;
                    break;
                }
            }
        }

        return (farmerTransaction, matchedProcessorTransactions, matchedRetailerTransactions);
    }
}
