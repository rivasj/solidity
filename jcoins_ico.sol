// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract jcoin_ico {
    
    // Introducing max jcoins available for sale
    uint public max_jcoins = 1000000;
    
    // Introducing USD to jcoins conversion rate
    uint public usd_to_jcoins = 1000;
    
    // Introducing total jcoins bought
    uint public total_jcoins_bought = 0;
    
    // Mapping investor address to equity
    mapping(address => uint) equity_jcoins;
    mapping(address => uint) equity_usd;
    
    // Checking if an investor can buy jcoins
    modifier can_buy_jcoins(uint usd_invested) {
        require(usd_invested * usd_to_jcoins + total_jcoins_bought <= max_jcoins, "Not enough jcoins remaining");
        _;
    }
    
    // Equity in jcoins of investor
    function equity_in_jcoins(address investor) external returns (uint){
        return equity_jcoins[investor];
    }
    
    // Equity in USD of investor
    function equity_in_usd(address investor) external returns (uint){
        return equity_usd[investor];
    }
    
    // Buy jcoins
    function buy_jcoins(address investor, uint usd_invested) external 
    can_buy_jcoins(usd_invested) {
        uint amount_jcoins = usd_invested * usd_to_jcoins;
        equity_jcoins[investor] += amount_jcoins;
        equity_usd[investor] = equity_jcoins[investor] / 1000;
        total_jcoins_bought += amount_jcoins;
    }
    
    // Sell jcoins
    function sell_jcoins(address investor, uint jcoins_sold) external {
        equity_jcoins[investor] -= jcoins_sold;
        equity_usd[investor] = equity_jcoins[investor] / 1000;
        total_jcoins_bought -= jcoins_sold;
    }
}
