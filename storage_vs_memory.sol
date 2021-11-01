// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract A {
    string[] public cities = ['Prague', 'Bucharest'];
    
    // will not change state variable cities
    function f_memory() public {
        string[] memory s1 = cities;
        s1[0] = 'Denver';
    }
    
    // will change state variable cities
    function f_storage() public {
        string[] storage s1 = cities;
        s1[0] = 'Denver';
    }
}
