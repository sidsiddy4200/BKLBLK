// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Oracle {
    struct Data {
        uint humidity;
        uint moistureContent;
        uint storageConditions;
    }

    mapping(address => Data) public data;

    // Unified function to either provide or get data
    function manageData(
        string memory action,
        address processorAddress,
        uint humidity,
        uint moistureContent,
        uint storageConditions
    ) public returns (uint, uint, uint) {
        if (keccak256(abi.encodePacked(action)) == keccak256("provide")) {
            data[processorAddress] = Data(humidity, moistureContent, storageConditions);
            return (0, 0, 0);  // Return dummy values as this branch doesn't need to return anything meaningful
        } else if (keccak256(abi.encodePacked(action)) == keccak256("get")) {
            Data memory d = data[processorAddress];
            return (d.humidity, d.moistureContent, d.storageConditions);
        } else {
            revert("Invalid action");
        }
    }
}
