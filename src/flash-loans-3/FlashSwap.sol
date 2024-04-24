// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

/**
 * @title FlashSwap
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract FlashSwap {
    IPair pair;
    address token;

    constructor(address _pair) {
        pair = IPair(_pair);
    }

    // TODO: Implement this function
    function executeFlashSwap(address _token, uint256 _amount) external {
        token = _token;
        console.log("Initial Token Balance", IERC20(_token).balanceOf(address(this)));
        pair.swap(_amount, 0, address(this), "some data");
    }

    // TODO: Implement this function
    function uniswapV2Call(address, uint256 amount0, uint256, bytes calldata) external {
        console.log("During Token Balance", IERC20(token).balanceOf(address(this)));
        uint256 fee = (amount0 * 3) / 997 + 1;
        console.log("FEE", fee);

        // Do something with flash swap

        IERC20(token).transfer(address(pair), amount0 + fee);
    }
}
