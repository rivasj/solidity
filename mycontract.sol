// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract Property {
    int public price;
    string public location = "London";
    address immutable public owner;
    int immutable area = 100;

    constructor(int _price, string memory _location) {
        price = _price;
        location = _location;
        owner = msg.sender;
    }
    
    function setPrice(int _price) public {
        price = _price;
    }
    
    function setLocation(string memory _location) public {
        location = _location;
    }
    
}


