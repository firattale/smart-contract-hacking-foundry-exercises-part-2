// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/ICallbackContract.sol";

contract AttackContract {
    function beforeExecution() external view {
        // TODO: Implement your malicious beforeExecution callback
    }

}
