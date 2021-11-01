// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// Decentralized lottery

/*
    Lottery starts by accepting ETH transactions. Anyone having an Ethereum wallet can send
    a fixed amount of 0.1 ETH to the contract's address. The players send directly to the
    contract address and their address is registered in a dynamic array. A user can send
    more transactions having more chances to win.
    
    There is a manager, the account that deploys and controls the contract.
    At some point, if there are >=3 entries, the manager can pick a random winner from the
    players list. Only the manager is allowed to see the contract balance and to randomly
    select the winner.
    
    The contract will transfer the entire balance to the winner's address and the lottery is
    reset for the next round.
*/

contract Lottery {
    address payable[] public entries;
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    receive() external payable {
        require(msg.value == 0.1 ether);
        entries.push(payable(msg.sender));
    }
    
    function getBalance() public view returns(uint) {
        require(msg.sender == owner);
        return address(this).balance;
    }
    
    function selectWinner() public {
        require(msg.sender == owner && entries.length > 2);
        
        uint index = random() % entries.length;
        address payable winner = entries[index];
        
        winner.transfer(getBalance());

        entries = new address payable[](0); // reset the lottery
    }
    
    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, entries.length)));
    }
}
