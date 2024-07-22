// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RetailerCustomer {

    struct WheatProduct {
        uint productType;
        string wheatType;
        string brand;
        string origin;
        uint price;
        string description;
        uint stock;
        address retailer;
    }

    struct Transaction {
        uint productType;
        uint quantity;
        uint[] offerIds;
        string status;
        address customer;
        address retailer;
    }

    mapping(uint => WheatProduct) public products;
    uint[] public productTypes;  // Array to store all productTypes

    mapping(uint => Transaction) public transactions;
    uint public nextTransactionId = 1;

    // Unified function to manage products
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
        if (keccak256(abi.encodePacked(action)) == keccak256("create")) {
            require(products[_productType].retailer == address(0), "Product already exists");
            products[_productType] = WheatProduct(_productType, _wheatType, _brand, _origin, _price, _description, _stock, msg.sender);
            productTypes.push(_productType);  // Add productType to the array when creating a product
        } else if (keccak256(abi.encodePacked(action)) == keccak256("update")) {
            require(products[_productType].retailer == msg.sender, "Only the retailer who created the product can update it");

            if (bytes(_wheatType).length > 0) {
                products[_productType].wheatType = _wheatType;
            }
            if (bytes(_brand).length > 0) {
                products[_productType].brand = _brand;
            }
            if (bytes(_origin).length > 0) {
                products[_productType].origin = _origin;
            }
            if (_price > 0) {
                products[_productType].price = _price;
            }
            if (bytes(_description).length > 0) {
                products[_productType].description = _description;
            }
            if (_stock > 0) {
                products[_productType].stock = _stock;
            }
        } else if (keccak256(abi.encodePacked(action)) == keccak256("remove")) {
            require(products[_productType].retailer == msg.sender, "Only the retailer who created the product can remove it");
            delete products[_productType];
        } else {
            revert("Invalid action");
        }
    }

    // Unified function to manage transactions
    function manageTransaction(
        string memory action,
        uint _productType,
        uint _quantity,
        uint _transactionId,
        uint[] memory _offerIds
    ) public {
        if (keccak256(abi.encodePacked(action)) == keccak256("buy")) {
            require(products[_productType].retailer != address(0), "Product does not exist");
            require(products[_productType].stock >= _quantity, "Not enough stock");

            products[_productType].stock -= _quantity;
            transactions[nextTransactionId] = Transaction(_productType, _quantity, new uint[](0), "Incomplete", msg.sender, products[_productType].retailer);
            nextTransactionId++;
        } else if (keccak256(abi.encodePacked(action)) == keccak256("update")) {
            require(keccak256(abi.encodePacked(transactions[_transactionId].status)) == keccak256(abi.encodePacked("Incomplete")), "Transaction is not incomplete");
            require(products[transactions[_transactionId].productType].retailer == msg.sender, "Only the retailer of the product can update the transaction");

            transactions[_transactionId].offerIds = _offerIds;
            transactions[_transactionId].status = "Complete";
        } else {
            revert("Invalid action");
        }
    }

    // Separate function to view all transactions
    function viewTransactions() public view returns (Transaction[] memory) {
        Transaction[] memory transactionsArray = new Transaction[](nextTransactionId - 1);
        for (uint i = 1; i < nextTransactionId; i++) {
            transactionsArray[i - 1] = transactions[i];
        }
        return transactionsArray;
    }

    // View function to get all products or a specific product
    function viewProduct(uint _productType) public view returns (WheatProduct[] memory) {
        if (_productType == 0) {
            uint productCount = productTypes.length;
            WheatProduct[] memory allProducts = new WheatProduct[](productCount);
            for (uint i = 0; i < productCount; i++) {
                allProducts[i] = products[productTypes[i]];
            }
            return allProducts;
        } else {
            require(products[_productType].retailer != address(0), "Product does not exist");
            WheatProduct[] memory product = new WheatProduct[](1);
            product[0] = products[_productType];
            return product;
        }
    }

    /**
     * @dev Returns all the transactions
     * @return An array of all Transaction structs
     */
    function getAllTransactions() public view returns (Transaction[] memory) {
        Transaction[] memory transactionsArray = new Transaction[](nextTransactionId);
        for (uint i = 1; i < nextTransactionId; i++) {
            transactionsArray[i - 1] = transactions[i];
        }
        return transactionsArray;
    }
}
