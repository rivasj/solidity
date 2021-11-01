// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FixedSizedArrays {
    uint[3] public numbers = [1, 2, 3];
    
    bytes1 public b1;
    bytes2 public b2;
    bytes3 public b3;
    //.. up to bytes32
    
    function setElement(uint index, uint value) public {
        numbers[index] = value;
    }
    
    function getLength() public view returns(uint) {
        return numbers.length;
    }
    
    function setBytesArray() public {
        b1 = 'a';
        b2 = 'ab';
        b3 = 'z';
    }
    
}
