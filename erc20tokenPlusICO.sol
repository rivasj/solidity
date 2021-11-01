// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract Cryptos is ERC20Interface {
    
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0; //18 is most used
    uint public override totalSupply; //getter function auto-created
    mapping(address => mapping(address => uint)) public allowed;
    
    address public founder;
    mapping(address => uint) public balances;
    
    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }
    
    function transfer(address to, uint tokens) public virtual override returns (bool success) {
        require(balances[msg.sender] >= tokens);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        
        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success) {
        require(allowed[from][to] >= tokens);
        require(balances[from] >= tokens);
        
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;
        
        emit Transfer(from, to, tokens);
        return true;
    }
}


contract CryptosICO is Cryptos {
    address public admin;
    address payable public deposit;
    uint tokenPrice = 0.001 ether; // 1ETH = 1000 CRPT
    uint constant public minInvestment = .01 ether;
    uint constant public maxInvestment = 5 ether;
    uint constant public hardCap = 300 ether;
    uint public raisedAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; // ICO ends in one week
    uint public tokenTradeStart = saleEnd + 604800;
    
    enum State{BeforeStart, Running, AfterEnd, Halted}
    State public icoState;
    
    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.BeforeStart;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    
    function changeDepositAddress(address payable _deposit) public onlyAdmin {
        deposit = _deposit;
    }
    
    function halt() public onlyAdmin {
        icoState = State.Halted;
    }
    
    function resume() public onlyAdmin {
        icoState = State.Running;
    }
    
    function getCurrentState() public view returns(State) {
        if(icoState == State.Halted) {
            return State.Halted;
        } else if(block.timestamp < saleStart) {
            return State.BeforeStart;
        } else if(block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.Running;
        } else {
            return State.AfterEnd;
        }
    }
    
    event Invest(address investor, uint value, uint tokens);
    
    function invest() public payable returns(bool) {
        icoState = getCurrentState();
        require(icoState == State.Running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);
        
        uint tokens = msg.value / tokenPrice;
        
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);
        
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }
    
    receive() payable external{
        invest();
    }
    
    function transfer(address to, uint tokens) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
        return Cryptos.transfer(to, tokens);
    }
    
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
        return this.transferFrom(from, to, tokens);
    }
    
    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.AfterEnd);
        balances[founder] = 0;
        return true;
    }
}

