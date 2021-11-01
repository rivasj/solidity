// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract GlobalVariables {
    
    uint public this_moment = block.timestamp;
    uint public block_number = block.number;
    uint public difficulty = block.difficulty;
    uint public gaslimit = block.gaslimit;
    
    address public owner;
    uint public sentValue;
    
    constructor() {
        owner = msg.sender;
    }
    
    function changeOwner() public {
        owner = msg.sender;
    }
    
    function sendEther() public payable {
        sentValue = msg.value;
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function howMuchGas() public view returns(uint) {
        uint start = gasleft();
        uint j = 1;
        for(uint i = 1; i < 20; i++) {
            j *= i;
        }
        uint end = gasleft();
        return start - end;
    }
}
