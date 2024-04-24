// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/ILendingPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title FlashLoan
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract FlashLoan {
    ILendingPool pool;

    constructor(address _pool) {
        pool = ILendingPool(_pool);
    }

    // TODO: Implement this function
    function getFlashLoan(address token, uint256 amount) external {
        IERC20(token).approve(address(pool), amount * 2);
        address[] memory assets = new address[](1);
        assets[0] = token;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        console.log("INITIAL TOKEN BALANCE %s", IERC20(token).balanceOf(address(this)) / 10 ** 6);

        pool.flashLoan(address(this), assets, amounts, modes, address(this), "", 0);
    }

    // TODO: Implement this function
    function executeOperation(
        address[] memory assets,
        uint256[] memory,
        uint256[] memory premiums,
        address,
        bytes memory
    ) public view returns (bool) {
        console.log("DURING FLOAN TOKEN BALANCE", IERC20(assets[0]).balanceOf(address(this)) / 10 ** 6);
        console.log("FEE", premiums[0] / 10 ** 6);
        // DO something with flash loan
        return true;
    }
}
