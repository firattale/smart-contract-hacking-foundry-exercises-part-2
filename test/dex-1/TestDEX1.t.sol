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
    Chocolate chocolate;
    IUniswapV2Pair pair;

    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant RICH_SIGNER = address(0x8EB8a3b98659Cce290402893d0123abb75E3ab28);

    uint128 constant ETH_BALANCE = 300 ether;
    uint128 constant INITIAL_MINT = 1000000 ether;
    uint128 constant INITIAL_LIQUIDITY = 100000 ether;
    uint128 constant ETH_IN_LIQUIDITY = 100 ether;

    uint128 constant TEN_ETH = 10 ether;
    uint128 constant HUNDRED_CHOCOLATES = 100 ether;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    IERC20 weth = IERC20(WETH_ADDRESS);

    function setUp() public {
        vm.label(WETH_ADDRESS, "WETH");
        vm.deal(deployer, 100 ether);
        vm.deal(user, 100 ether);
    }

    function testDex1() public {
        // --------------- Deploy ---------------
        // TODO: Deploy your smart contract to `chocolate`, mint 1,000,000 tokens to deployer
        
        // TODO: Print newly created pair address and store pair contract to `this.pair`

        // --------------- Add Liquidity ---------------
        // TODO: Add liquidity of 100,000 tokens and 100 ETH (1 token = 0.001 ETH)
        
        // TODO: Print the amount of LP tokens that the deployer owns

        // --------------- Swap ---------------
        // TODO: From user: Swap 10 ETH to Chocolate

        // TODO: Make sure user received the chocolates (greater amount than before)
        uint256 userChocBalance = chocolate.balanceOf(user);
        
        // TODO: From user: Swap 100 Chocolates to ETH
        uint256 userInitialWethBalance = weth.balanceOf(user);
        
        // TODO: Make sure user received the WETH (greater amount than before)

        // --------------- Remove Liquidity ---------------

        // TODO: Remove 50% of deployer's liquidity

        // TODO: Make sure deployer owns 50% of the LP tokens (leftovers)

        // TODO: Make sure deployer got chocolate and weth back (greater amount than before)
    }
}
