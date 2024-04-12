// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/flash-loan-attacks-2/AdvancedVault.sol";

/**
 * @dev run "forge test -vvv --match-contract FLA2"
 */
contract TestFLA2 is Test {

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    uint256 constant ETH_IN_VAULT = 1000 ether;
    AdvancedVault vault;
    uint256 attackerInitialBalance;

    function setUp() public {
        /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.deal(deployer, ETH_IN_VAULT);
        vm.startPrank(deployer);

        vault = new AdvancedVault{value: ETH_IN_VAULT}();
        attackerInitialBalance = attacker.balance;
        assertEq(address(vault).balance, ETH_IN_VAULT);
        vm.stopPrank();
    }

    function testFlashLoanAttack() public {
        /** CODE YOUR SOLUTION HERE */

        /** SUCCESS CONDITIONS */
        assertEq(address(vault).balance, 0);
        assertGe(attacker.balance, attackerInitialBalance + ETH_IN_VAULT);
    }
}
