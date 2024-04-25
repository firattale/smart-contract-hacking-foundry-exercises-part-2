// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/dos-2/Auction.sol";
import "src/dos-2/AttackAuction.sol";

/**
 * @dev run "forge test -vvv --match-contract DOS2"
 */
contract TestDOS2 is Test {
    uint256 constant USER1_FIRST_BID = 5 ether;
    uint256 constant USER2_FIRST_BID = 6.5 ether;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    Auction auction;

    function setUp() public {
        /**
         * SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
         */
        vm.prank(deployer);
        auction = new Auction();

        vm.deal(user1, 100 ether);
        vm.prank(user1);
        auction.bid{value: USER1_FIRST_BID}();

        vm.deal(user2, 100 ether);
        vm.prank(user2);
        auction.bid{value: USER2_FIRST_BID}();

        assertEq(auction.highestBid(), USER2_FIRST_BID);
        assertEq(auction.currentLeader(), user2);
    }

    function testDosAttack() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        AttackAuction attackAuction = new AttackAuction(address(auction));
        vm.deal(address(attackAuction), 10 ether);
        attackAuction.attack();

        vm.stopPrank();

        /**
         * SUCCESS CONDITIONS
         */
        uint256 highestBid = auction.highestBid();
        vm.startPrank(user2);
        vm.expectRevert();
        auction.bid{value: highestBid * 3}();
        // User1 and User2 are not currentLeader
        assertTrue(auction.currentLeader() != address(user1));
        assertTrue(auction.currentLeader() != address(user2));
    }
}
