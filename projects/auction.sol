// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    Decentralized Auction
    
    The auction has an owner (the seller), a start and end date.
    
    The owner can cancel the auction if there is an emergency or can finalize the auction
    after the end time.
    
    People send ETH by calling a function placeBid(). The sender's address and the value
    sent to the auction will be stored in mapping variable called bids.
    
    Users are incentivized to bid the maximum they're willing to pay, but they are not
    bound to that full amount, but rather to the previous highest bid plus an increment.
    The contract will automatically bid up to a given amount.
    
    The highestBindingBid is the selling price the the highestBidder the person who won
    the auction.
    
    After the auction ends the owner gets the highestBindingBid and everybody else
    withdraws their own amount.
*/

contract Auction {
    
    address payable public owner;
    uint constant public increment = 100;
    uint public highestBid;
    uint public highestBindingBid;
    address payable highestBidder;
    mapping(address => uint) bids;
    address payable[] bidders;
    
    string public ipfsHash;
    enum State {Started, Running, Ended, Canceled}
    State public auctionState;
    uint public startBlock;
    uint public endBlock;
    
    constructor() {
        owner = payable(msg.sender);
        startBlock = block.number;
        endBlock = startBlock + 3; // 3 blocks static limit on auction
        auctionState = State.Running;
        ipfsHash = "";
    }
    
    modifier isOwner() {
        require(msg.sender == owner);
        _; 
    }
    
    modifier notOwner() {
        require(msg.sender != owner);
        _; 
    }
    
    modifier afterStart() {
        require(block.number >= startBlock);
        _;
    }
    
    modifier beforeEnd() {
        require(block.number <= endBlock);
        _;
    }
    
    function placeBid() payable public notOwner afterStart beforeEnd {
        require(auctionState == State.Running);
        
        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestBindingBid);
        if(bids[msg.sender] == 0) {
            bidders.push(payable(msg.sender));
        }
        bids[msg.sender] = currentBid;
        
        // if bid amount < highestBid, update highestBindingBid and nothing else
        // else, update highestBid, highestBindingBid, highestBidder
        if(currentBid < highestBid) {
            highestBindingBid = msg.value + 100;
        } else {
            if(currentBid < highestBid + 100) {
                highestBindingBid = currentBid;
            } else {
                highestBindingBid = highestBid + 100;
            }
            highestBid = currentBid;
            highestBidder = payable(msg.sender);
        }
    }
    
    function cancelAution() public isOwner {
        auctionState = State.Canceled;
    }
    
    function finalizeAution() public {
        require(auctionState == State.Canceled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        address payable recipient;
        uint value;
        
        if(auctionState == State.Canceled) {
            recipient = payable(msg.sender);
            value = bids[msg.sender];
        } else { // auction ended, not canceled
            if(msg.sender == owner) {
                recipient = owner;
                value = highestBindingBid;
            } else {
                if(msg.sender == highestBidder) {
                    recipient = highestBidder;
                    value = bids[highestBidder] - highestBindingBid;
                } else {
                    recipient = payable(msg.sender);
                    value = bids[msg.sender];
                }
            }
        }
        
        recipient.transfer(value);
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
}
