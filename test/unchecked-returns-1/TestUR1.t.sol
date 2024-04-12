// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/unchecked-returns-1/DonationMaster.sol";
import "src/unchecked-returns-1/MultiSigSafe.sol";

/**
 * @dev run "forge test -vvv --match-contract UR1"
 */
contract TestUR1 is Test {
    
    uint256 constant ONE_ETH = 1 ether;
    uint256 constant HUNDRED_ETH = 100 ether;
    uint256 constant THOUSAND_ETH = 1000 ether;

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    DonationMaster donationMaster;
    MultiSigSafe multiSig;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.deal(deployer, 10_000 ether);
        vm.startPrank(deployer);
        donationMaster = new DonationMaster();
        address[] memory signers = new address[](3);
        signers[0] = user1;
        signers[1] = user2;
        signers[2] = user3;
        multiSig = new MultiSigSafe(signers, 2);
    }

    function testsDonation() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

        // New donation works
        donationMaster.newDonation(address(multiSig), HUNDRED_ETH);
        uint256 donationId = donationMaster.donationsNo() - 1;

        // Donating to multisig wallet works
        donationMaster.donate{value: ONE_ETH}(donationId);

        // Validate donation details
        (uint256 id, address to, uint256 goal, uint256 donated) = donationMaster.donations(donationId);
        assertEq(id, donationId);
        assertEq(to, address(multiSig));
        assertEq(goal, uint256(HUNDRED_ETH));
        assertEq(donated, uint256(ONE_ETH));

        // Too big donation fails (goal reached)
        vm.expectRevert();
        donationMaster.donate{value: THOUSAND_ETH}(donationId);
    }

    // Note: Test is marked as expected to fail (by having Fail in the name)
    // Here you have to demonstrate the bug, therefore the test should be failing.
    function testFailFixedTests() public {
        /* CODE YOUR SOLUTION HERE */
		/* Write the correct tests here */
        
    }
}