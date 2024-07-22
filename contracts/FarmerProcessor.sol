// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FarmerProcessor {
    struct Order {
        uint id;
        uint quantity;
        string status;
        address processor;
    }

    struct Offer {
        uint id;
        uint orderId;
        string harvestDate;
        uint pricePerKilogram;
        string origin;
        string status;
        address farmer;
    }

    struct Transaction {
        uint orderId;
        uint offerId;
        uint timestamp;
        address farmer;
        address processor;
    }

    mapping(uint => Order) public orders;
    mapping(uint => Offer) public offers;
    mapping(uint => Transaction) public transactions;
    uint public nextOrderId = 1;
    uint public nextOfferId = 1;
    uint public nextTransactionId = 1;

    /**
     * @dev Processor can create a new order, cancel an order, or view an order
     * @param action The action to perform: "create", "cancel", or "view"
     * @param _orderId The id of the order to cancel or view (ignored for creation)
     * @param _quantity The quantity of wheat (In Litre) for creation (ignored for cancel or view)
     * @return Order information for view action, or order id for create and cancel actions
     */
    function manageOrder(string memory action, uint _orderId, uint _quantity) public returns (uint, uint, string memory, address) {
        if (keccak256(abi.encodePacked(action)) == keccak256("create")) {
            orders[nextOrderId] = Order(nextOrderId, _quantity, "In progress", msg.sender);
            uint current = nextOrderId;
            nextOrderId++;
            return (current, 0, "", address(0));
        } else if (keccak256(abi.encodePacked(action)) == keccak256("cancel")) {
            require(orders[_orderId].processor == msg.sender, "Only the processor who created the order can cancel it");
            orders[_orderId].status = "Cancelled";
            return (_orderId, 0, "", address(0));
        } else if (keccak256(abi.encodePacked(action)) == keccak256("view")) {
            Order memory order = orders[_orderId];
            return (order.id, order.quantity, order.status, order.processor);
        } else {
            revert("Invalid action");
        }
    }

    /**
     * @dev Farmer can create an offer, cancel an offer, or view offers for a specific order
     * @param action The action to perform: "create", "cancel", or "view"
     * @param _offerId The id of the offer to cancel (ignored for creation and view)
     * @param _orderId The id of the order this offer is related to (ignored for cancel)
     * @param _harvestDate The production date of wheat (ignored for cancel and view)
     * @param _pricePerKilogram The price per kilogram of wheat (ignored for cancel and view)
     * @param _origin The origin of the wheat (ignored for cancel and view)
     * @return Offer information for view action, or offer id for create and cancel actions
     */
    function manageOffer(string memory action, uint _offerId, uint _orderId, string memory _harvestDate, uint _pricePerKilogram, string memory _origin) public returns (Offer[] memory, uint) {
        if (keccak256(abi.encodePacked(action)) == keccak256("create")) {
            offers[nextOfferId] = Offer(nextOfferId, _orderId, _harvestDate, _pricePerKilogram, _origin, "In progress", msg.sender);
            uint current = nextOfferId;
            nextOfferId++;
            Offer[] memory emptyOffers;
            return (emptyOffers, current);
        } else if (keccak256(abi.encodePacked(action)) == keccak256("cancel")) {
            require(offers[_offerId].farmer == msg.sender, "Only the farmer who created the offer can cancel it");
            offers[_offerId].status = "Cancelled";
            Offer[] memory emptyOffers;
            return (emptyOffers, _offerId);
        } else if (keccak256(abi.encodePacked(action)) == keccak256("view")) {
            uint offerCount = 0;
            for (uint i = 1; i < nextOfferId; i++) {
                if (offers[i].orderId == _orderId && keccak256(abi.encodePacked(offers[i].status)) == keccak256(abi.encodePacked("In progress"))) {
                    offerCount++;
                }
            }

            Offer[] memory activeOffers = new Offer[](offerCount);
            uint counter = 0;
            for (uint i = 1; i < nextOfferId; i++) {
                if (offers[i].orderId == _orderId && keccak256(abi.encodePacked(offers[i].status)) == keccak256(abi.encodePacked("In progress"))) {
                    activeOffers[counter] = offers[i];
                    counter++;
                }
            }

            return (activeOffers, 0);
        } else {
            revert("Invalid action");
        }
    }

    /**
     * @dev Processor can accept an offer and create a transaction
     * @param _orderId The id of the order
     * @param _offerId The id of the offer
     * @return The id of the created transaction
     */
    function acceptOffer(uint _orderId, uint _offerId) public returns (uint) {
        require(orders[_orderId].processor == msg.sender, "Only the processor who created the order can accept offers");
        require(keccak256(abi.encodePacked(orders[_orderId].status)) == keccak256(abi.encodePacked("In progress")), "Order must be in progress");
        require(keccak256(abi.encodePacked(offers[_offerId].status)) == keccak256(abi.encodePacked("In progress")), "Offer must be in progress");
        require(offers[_offerId].orderId == _orderId, "Offer must correspond to the order");

        offers[_offerId].status = "Completed";
        orders[_orderId].status = "Completed";
        transactions[nextTransactionId] = Transaction(_orderId, _offerId, block.timestamp, offers[_offerId].farmer, orders[_orderId].processor);
        uint currentTransactionId = nextTransactionId;
        nextTransactionId++;
        return currentTransactionId;
    }

    /**
     * @dev Returns all the transactions
     * @return An array of all Transaction structs
     */
    function getAllTransactions() public view returns (Transaction[] memory) {
        Transaction[] memory transactionsArray = new Transaction[](nextTransactionId - 1);
        for (uint i = 1; i < nextTransactionId; i++) {
            transactionsArray[i - 1] = transactions[i];
        }
        return transactionsArray;
    }
}
