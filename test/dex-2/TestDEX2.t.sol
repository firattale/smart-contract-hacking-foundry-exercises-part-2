// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/dex-2/Sniper.sol";
import {IUniswapV2Router02} from "src/interfaces/IUniswapV2.sol";
import "src/interfaces/IWETH9.sol";
import "src/utils/DummyERC20.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 15969633 --match-contract DEX2"
 */
contract TestDEX2 is Test {
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant UNISWAPV2_ROUTER_ADDRESS = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant UNISWAPV2_FACTORY_ADDRESS = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    uint128 constant ETH_BALANCE = 300 ether;

    uint128 constant INITIAL_MINT = 80000 ether;
    uint128 constant INITIAL_LIQUIDITY = 10000 ether;
    uint128 constant ETH_IN_LIQUIDITY = 50 ether;

    uint128 constant ETH_TO_INVEST = 35 ether;
    uint128 constant MIN_AMOUNT_OUT = 1750 ether;

    address liquidityAdder = makeAddr("liquidityAdder");
    address user = makeAddr("user");

    IWETH9 weth = IWETH9(WETH_ADDRESS);
    IUniswapV2Router02 router;
    DummyERC20 preciousToken;
    Sniper sniper;

    function setUp() public {
        vm.label(WETH_ADDRESS, "WETH");
        vm.label(UNISWAPV2_ROUTER_ADDRESS, "UniswapV2Router02");
        vm.label(UNISWAPV2_FACTORY_ADDRESS, "UniswapV2Factory");

        // Set ETH balance
        vm.deal(liquidityAdder, ETH_BALANCE);
        vm.deal(user, ETH_BALANCE);

        vm.startPrank(liquidityAdder);

        // Deploy token
        preciousToken = new DummyERC20("PreciousToken", "PRECIOUS", INITIAL_MINT);

        // Load Uniswap Router contract
        router = IUniswapV2Router02(UNISWAPV2_ROUTER_ADDRESS);

        // Set the liquidity add operation deadline
        uint deadline = block.timestamp + 10000;

        // Deposit to WETH & approve router to spend tokens
        weth.deposit{value: ETH_IN_LIQUIDITY}();
        weth.approve(UNISWAPV2_ROUTER_ADDRESS, ETH_IN_LIQUIDITY);
        preciousToken.approve(UNISWAPV2_ROUTER_ADDRESS, INITIAL_LIQUIDITY);

        // Add the liquidity 10,000 PRECIOUS & 50 WETH
        router.addLiquidity(
            address(preciousToken),
            WETH_ADDRESS,
            INITIAL_LIQUIDITY,
            ETH_IN_LIQUIDITY,
            INITIAL_LIQUIDITY,
            ETH_IN_LIQUIDITY,
            liquidityAdder,
            deadline
        );

        vm.stopPrank();
    }

    function testAttack() public {
        // TODO: Deploy your smart contract 'sniper`

        // TODO: Sniper the tokens using your snipe function
        // NOTE: Your rich friend is willing to invest 35 ETH in the project, and is willing to pay 0.02 WETH per PRECIOUS
        // Which is 4x time more expensive than the initial liquidity price.
        // You should retry 3 times to buy the token.
        // Make sure to deposit to WETH and send the tokens to the sniper contract in advance

        /** SUCCESS CONDITIONS */

        // Bot was able to snipe at least 4,000 precious tokens
        // Bought at a price of ~0.00875 ETH per token (35 / 4000)
        uint preciousBalance = preciousToken.balanceOf(user);
        console.log("Sniped Balance: ", preciousBalance);
        assertEq(preciousBalance > 1 ether, true);
    }
}
