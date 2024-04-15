// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/dex-1/Chocolate.sol";
import {IUniswapV2Pair} from "src/interfaces/IUniswapV2.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 15969633 --match-contract DEX1"
 */
contract TestDEX1 is Test {
    Chocolate public chocolate;
    IUniswapV2Pair public pair;

    address public constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint128 public constant ETH_BALANCE = 300 ether;
    uint128 public constant INITIAL_MINT = 1_000_000 ether;
    uint128 public constant INITIAL_LIQUIDITY = 100_000 ether;
    uint128 public constant ETH_IN_LIQUIDITY = 100 ether;

    uint128 public constant TEN_ETH = 10 ether;
    uint128 public constant HUNDRED_CHOCOLATES = 100 ether;

    address public deployer = makeAddr("deployer");
    address public user = makeAddr("user");

    IERC20 public weth = IERC20(WETH_ADDRESS);

    function setUp() public {
        vm.label(WETH_ADDRESS, "WETH");
        vm.label(user, "USER");
        vm.label(deployer, "DEPLOYER");
        vm.deal(deployer, 100 ether);
        vm.deal(user, 100 ether);
    }

    function testDex1() public {
        // --------------- Deploy ---------------
        // TODO: Deploy your smart contract to `chocolate`, mint 1,000,000 tokens to deployer
        vm.startPrank(deployer);

        chocolate = new Chocolate(INITIAL_MINT);

        // TODO: Print newly created pair address and store pair contract to `this.pair`
        console.log("Pair address", chocolate.uniswapV2PairAddress());
        pair = IUniswapV2Pair(chocolate.uniswapV2PairAddress());

        // --------------- Add Liquidity ---------------
        // TODO: Add liquidity of 100,000 tokens and 100 ETH (1 token = 0.001 ETH)
        chocolate.approve(address(chocolate), INITIAL_LIQUIDITY);
        // weth.approve(address(chocolate), ETH_IN_LIQUIDITY);
        chocolate.addChocolateLiquidity{value: ETH_IN_LIQUIDITY}(INITIAL_LIQUIDITY);

        // TODO: Print the amount of LP tokens that the deployer owns
        console.log("Balance of LP tokens", pair.balanceOf(deployer));

        vm.stopPrank();

        // --------------- Swap ---------------
        // TODO: From user: Swap 10 ETH to Chocolate

        vm.startPrank(user);
        uint256 userChocBalance = chocolate.balanceOf(user);
        console.log("Initial Choc Balance", userChocBalance);
        chocolate.swapChocolates{value: TEN_ETH}(WETH_ADDRESS, TEN_ETH);

        // TODO: Make sure user received the chocolates (greater amount than before)
        userChocBalance = chocolate.balanceOf(user);
        console.log("After Swap Choc Balance", userChocBalance);

        assertGt(userChocBalance, 0);

        // TODO: From user: Swap 100 Chocolates to ETH
        uint256 userWethBalance = weth.balanceOf(user);
        console.log("User Initial Weth Balance", userWethBalance);

        chocolate.approve(address(chocolate), HUNDRED_CHOCOLATES);

        chocolate.swapChocolates(address(chocolate), HUNDRED_CHOCOLATES);

        // TODO: Make sure user received the WETH (greater amount than before)
        userWethBalance = weth.balanceOf(user);
        console.log("User After swap Weth Balance", userWethBalance);
        assertGt(userWethBalance, 0);

        vm.stopPrank();
        // --------------- Remove Liquidity ---------------

        // TODO: Remove 50% of deployer's liquidity
        vm.startPrank(deployer);
        uint256 deployerPairBalance = pair.balanceOf(deployer);
        uint256 deployerInitChocBalance = chocolate.balanceOf(deployer);
        uint256 deployerInitWethBalance = weth.balanceOf(deployer);

        uint256 lpTokensToRemove = deployerPairBalance / 2;

        pair.approve(address(chocolate), lpTokensToRemove);

        chocolate.removeChocolateLiquidity(lpTokensToRemove);

        // TODO: Make sure deployer owns 50% of the LP tokens (leftovers)

        assertEq(pair.balanceOf(deployer), lpTokensToRemove);

        // TODO: Make sure deployer got chocolate and weth back (greater amount than before)
        assertGt(chocolate.balanceOf(deployer), deployerInitChocBalance);
        assertGt(weth.balanceOf(deployer), deployerInitWethBalance);
    }
}
