// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*
    Decentralized Crowd Funding smart contract
    
    Admin will start a campaign for CrowdFunding with a specific monetary goal and deadline.
    
    Contributors will contribute to that project by sending ETH by calling a function called
    contribute() or by sending it directly to the contract.
    
    The admin has to create a Spending Request each time they want to spend money for the 
    campaign. Can be created at any time, whether or not the campaign has ended. Once the
    request is created, the contributors can start voting on it. If >50% of the total
    contributors voted for the request, then the admin would have the permission to spend
    the amount specified in the request.
    
    Admin is allowed to make a payment only if the campaign goal is reached.
    
    The contibutors can request a refund in the monetary goal was not reached within the deadline.
*/

contract CrowdFunding {
    
    mapping(address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public goal;
    uint public deadline;
    uint public raisedAmount;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
    
    mapping(uint => Request) public requests;
    uint public numRequests;
    
    constructor(uint _goal, uint _deadline) {
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        admin = msg.sender;
    }
    
    event ContributeEvent(address _sender, uint _value);
    event CreateRequestEvent(string _description, address _recipient, uint _value);
    event MakePaymentEvent(address _recipient, uint _value);
    
    receive() external payable {
        contribute();
    }
    
    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline has passed!");
        require(msg.value >= 100, "Minimum contribution not met!");
        
        if(contributors[msg.sender] == 0) {
            noOfContributors++;
        }
        
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
        
        emit ContributeEvent(msg.sender, msg.value);
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function getRefund() public {
        require(block.timestamp > deadline && raisedAmount < goal);
        uint amount = contributors[msg.sender];
        require(amount > 0);
        
        address payable refundAddr = payable(msg.sender);
        refundAddr.transfer(amount);
        // noOfContributors--;
        // raisedAmount -= amount;
        contributors[msg.sender] = 0;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    modifier notAdmin() {
        require(msg.sender != admin);
        _;
    }
    
    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
        
        emit CreateRequestEvent(_description, _recipient, _value);
    }
    
    function vote(uint index) public notAdmin{
        require(contributors[msg.sender] > 0, "You must be a contributor to vote!");
        require(index <= numRequests);
        
        Request storage request = requests[index];
        require(request.voters[msg.sender] == false, "You have already voted!");
        
        request.voters[msg.sender] = true;
        request.noOfVoters++;
        // if(request.noOfVoters > noOfContributors/2) {
        //     request.completed = true;
        // }
    }
    
    function makePayment(uint index) public payable onlyAdmin {
        require(index <= numRequests);
        require(raisedAmount >= goal);
        Request storage request = requests[index];
        
        require(request.completed == false, "The request has already been completed");
        require(request.noOfVoters > noOfContributors/2, "Not enough votes for spending request");
        
        request.recipient.transfer(request.value);
        request.completed = true;
        
        emit MakePaymentEvent(request.recipient, request.value);
    }
}

