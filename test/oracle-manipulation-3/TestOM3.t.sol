// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/interfaces/IWETH9.sol";
import "src/oracle-manipulation-3/LendLand.sol";
import "src/oracle-manipulation-3/AttackLendLand.sol";

/**
 * @dev run "forge test -vvvv --fork-url mainnet --fork-block-number 15969633 --match-contract OM3"
 */
contract TestOM3 is Test {
    // Addresses
    address constant PAIR_ADDRESS = address(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11); // DAI/WETH
    address constant DAI_ADDRESS = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH
    address constant IMPERSONATED_ACCOUNT_ADDRESS = address(0xF977814e90dA44bFA03b6295A0616a897441aceC); // Binance Hot Wallet

    // Amounts
    uint256 constant WETH_LIQUIDITY = 1000 ether; // 1000 ETH
    uint256 constant DAI_LIQUIDITY = 1_500_000 ether; // 1.5m USD

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    LendLand lendLand;

    IWETH9 weth;
    IERC20 dai;

    // Attacker added constants
    address constant UNISWAPV2_ROUTER = address(0xf164fC0Ec4E93095b804a4795bBe1e041497b92a);
    address constant AAVE_POOL_V2 = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address constant AWETH_ADDRESS = address(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e);
    address constant ADAI_ADDRESS = address(0x028171bCA77440897B824Ca71D1c56caC55b68A3);

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

        // Attacker starts with 1 ETH
        vm.deal(attacker, 1 ether);
        assertEq(attacker.balance, 1 ether);

        // Deploy LendLand with DAI/WETH contract
        vm.startPrank(deployer);
        lendLand = new LendLand(PAIR_ADDRESS);

        // Load Tokens contract
        weth = IWETH9(WETH_ADDRESS);
        vm.label(WETH_ADDRESS, "WETH");
        dai = IERC20(DAI_ADDRESS);
        vm.label(DAI_ADDRESS, "DAI");

        // Convert ETH to WETH
        vm.deal(deployer, WETH_LIQUIDITY);
        weth.deposit{value: WETH_LIQUIDITY}();
        assertEq(weth.balanceOf(deployer), WETH_LIQUIDITY);

        // Deposit WETH from Deployer to LendLand
        weth.approve(address(lendLand), WETH_LIQUIDITY);
        lendLand.deposit(WETH_ADDRESS, WETH_LIQUIDITY);

        // WETH despoit succeded
        assertEq(weth.balanceOf(address(lendLand)), WETH_LIQUIDITY);
        assertEq(lendLand.deposited(address(weth), deployer), WETH_LIQUIDITY);

        // Depsit DAI on LendLand (from Binance hot wallet)
        vm.startPrank(IMPERSONATED_ACCOUNT_ADDRESS);
        dai.approve(address(lendLand), DAI_LIQUIDITY);
        lendLand.deposit(address(dai), DAI_LIQUIDITY);

        // DAI despoit succeded
        assertEq(dai.balanceOf(address(lendLand)), DAI_LIQUIDITY);
        assertEq(lendLand.deposited(address(dai), IMPERSONATED_ACCOUNT_ADDRESS), DAI_LIQUIDITY);

        // Didn't deposit WETH so can't borrow DAI
        vm.expectRevert();
        lendLand.borrow(address(dai), DAI_LIQUIDITY);

        // WETH depositor can borrow some DAI
        vm.startPrank(deployer);
        lendLand.borrow(address(dai), 100 ether);
    }

    function testOracle3Exploit() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        AttackLendLand attackLendLand = new AttackLendLand(
            PAIR_ADDRESS, address(lendLand), AAVE_POOL_V2, UNISWAPV2_ROUTER, AWETH_ADDRESS, ADAI_ADDRESS
        );
        attackLendLand.attack();

        /**
         * SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE
         */

        // Protocol Liquidity
        console.log("LendLand DAI balance: ", dai.balanceOf(address(lendLand)));
        console.log("LendLand WETH balance: ", weth.balanceOf(address(lendLand)));

        console.log("Attacker DAI balance: ", dai.balanceOf(address(attacker)));
        console.log("Attacker WETH balance: ", weth.balanceOf(address(attacker)));

        // // Pool liquidity should be at least -98%
        assertLt(dai.balanceOf(address(lendLand)), (DAI_LIQUIDITY * 2) / 100);
        assertLt(weth.balanceOf(address(lendLand)), (WETH_LIQUIDITY * 2) / 100);

        // // Attacker stole the liquidity - at least +92%
        assertGt(dai.balanceOf(attacker), (DAI_LIQUIDITY * 92) / 100);
        assertGt(weth.balanceOf(attacker), (WETH_LIQUIDITY * 92) / 100);
    }
}
