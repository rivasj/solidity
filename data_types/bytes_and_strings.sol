// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BytesAndStrings {
    bytes public b1 = 'abc';
    string public s1 = 'abc';
    
    function addElement() public {
        b1.push('x');
        // s1.push('x'); error
    }
    
    function getElement(uint index) public view returns (bytes1) {
        if (index < b1.length) {
            return b1[index];
        } else {
            return 0;
        }
    }
    
    function getLength() public view returns (uint) {
        return b1.length;
    }
}
