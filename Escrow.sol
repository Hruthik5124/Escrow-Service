// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

contract Escrow {
    struct Item {
        string name;
        uint256 price;
        address seller;
        address buyer;
        bool isSold;
    }

    mapping(string => Item) public items;
    mapping(address => uint256) public escrowBalances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function ListItem(string memory name, uint256 price) public {
        require(bytes(name).length > 0, "Item name cannot be empty");
        require(price > 0, "Price must be greater than zero");
        require(items[name].price == 0, "Item is already listed");

        items[name] = Item({
            name: name,
            price: price,
            seller: msg.sender,
            buyer: address(0),
            isSold: false
        });
    }

    function BuyItem(string memory name) public payable {
        Item storage item = items[name];
        require(item.price > 0, "Item not listed");
        require(!item.isSold, "Item already sold");
        require(msg.value == item.price, "Incorrect payment amount");

        item.buyer = msg.sender;
        escrowBalances[msg.sender] += msg.value;
    }

    function confirmationReciept(string memory name) public {
        Item storage item = items[name];
        require(item.buyer == msg.sender, "Only the buyer can confirm receipt");
        require(!item.isSold, "Item already confirmed");

        item.isSold = true;
        escrowBalances[msg.sender] -= item.price;
        payable(item.seller).transfer(item.price);
    }


    receive() external payable {
        revert("Direct payments not allowed");
    }
}
