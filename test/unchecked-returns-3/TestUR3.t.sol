// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/unchecked-returns-3/DAI.sol";
import "src/unchecked-returns-3/StableSwap.sol";
import "src/unchecked-returns-3/USDC.sol";
import "src/unchecked-returns-3/UST.sol";

/**
 * @dev run "forge test -vvv --match-contract UR3"
 */
contract TestUR3 is Test {
    
    uint256 constant TOKENS_INITIAL_SUPPLY = 100_000_000 ether;
    uint256 constant TOKENS_IN_STABLESWAP = 1_000_000 ether;
    uint256 constant CHAIN_ID = 31337;
    
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    UST ust;
    DAI dai;
    USDC usdc;
    StableSwap stableSwap;
    // StableSwapSecured stableSwap;

    uint256 stableSwapDAIBalance;
    uint256 stableSwapUSDCBalance;
    uint256 stableSwapUSTBalance;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.deal(deployer, 100 ether);
        vm.startPrank(deployer);

        // Deploy tokens
        ust = new UST(TOKENS_INITIAL_SUPPLY, "Terra USD", "UST", 6);
        dai = new DAI(CHAIN_ID);
        usdc = new USDC();
        vm.label(address(ust), "UST");
        vm.label(address(dai), "DAI");
        vm.label(address(usdc), "USDC");

        usdc.initialize("Center Coin", "USDC", "USDC", 6, deployer, deployer, deployer, deployer);

        // Mint tokens to deployer
        dai.mint(deployer, TOKENS_INITIAL_SUPPLY);
        usdc.configureMinter(deployer, TOKENS_INITIAL_SUPPLY);
        usdc.mint(deployer, TOKENS_INITIAL_SUPPLY);

        // Deploy StableSwap
        address[] memory tokens = new address[](3);
        tokens[0] = address(dai);
        tokens[1] = address(ust);
        tokens[2] = address(usdc);
        stableSwap = new StableSwap(tokens);
        // stableSwap = new StableSwapSecured(tokens);

        // Check allowed tokens
        assertTrue(stableSwap.isSupported(address(usdc), address(dai)));
        assertTrue(stableSwap.isSupported(address(usdc), address(ust)));

        // // Send tokens to StableSwap
        ust.transfer(address(stableSwap), TOKENS_IN_STABLESWAP);
        dai.transfer(address(stableSwap), TOKENS_IN_STABLESWAP);
        usdc.transfer(address(stableSwap), TOKENS_IN_STABLESWAP);

        // // Check StableSwap Balance
        assertEq(ust.balanceOf(address(stableSwap)), TOKENS_IN_STABLESWAP);
        assertEq(dai.balanceOf(address(stableSwap)), TOKENS_IN_STABLESWAP);
        assertEq(usdc.balanceOf(address(stableSwap)), TOKENS_IN_STABLESWAP);

        // Swap works, balances are ok
        uint256 amount = 100 * 10 ** 6;
        usdc.approve(address(stableSwap), amount);
        stableSwap.swap(address(usdc), address(dai), amount);
        assertEq(usdc.balanceOf(address(stableSwap)), TOKENS_IN_STABLESWAP + amount);
        assertEq(dai.balanceOf(address(stableSwap)), TOKENS_IN_STABLESWAP - amount);

        // Swap fails without allowance
        vm.expectRevert();
        stableSwap.swap(address(usdc), address(dai), amount);

        stableSwapDAIBalance = dai.balanceOf(address(stableSwap));
        stableSwapUSDCBalance = usdc.balanceOf(address(stableSwap));
        stableSwapUSTBalance = ust.balanceOf(address(stableSwap));
    }

    function testAttackStableSwap() public {
        /** CODE YOUR SOLUTION HERE */

        /** SUCCESS CONDITIONS */

		// Attacker was able to drain the entire protocol balance!
        assertEq(usdc.balanceOf(address(stableSwap)), 0);
        assertEq(dai.balanceOf(address(stableSwap)), 0);
        assertEq(ust.balanceOf(address(stableSwap)), 0);

        assertEq(usdc.balanceOf(address(attacker)), stableSwapUSDCBalance);
        assertEq(dai.balanceOf(address(attacker)), stableSwapDAIBalance);
        assertEq(ust.balanceOf(address(attacker)), stableSwapUSTBalance);
    }

}