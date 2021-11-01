// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract DynamicallySizedArrays {
    uint[] public numbers;
    
    function getLength() public view returns(uint) {
        return numbers.length;
    }
    
    function addElement(uint item) public {
        numbers.push(item);
    }
    
    function removeElement() public {
        numbers.pop();
    }
    
    function getElement(uint index) public view returns(uint) {
        if(index < numbers.length) {
            return numbers[index];
        }
        return 0;
    }
    
    function f() public {
        uint[] memory y = new uint[](3);
        y[0] = 10;
        y[1] = 20;
        y[2] = 30;
        numbers = y;
    }
}
