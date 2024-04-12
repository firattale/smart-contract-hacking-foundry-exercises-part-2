// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/flash-loans-2/FlashLoan.sol";
import "src/interfaces/ILendingPool.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 15969633 --match-contract FL2"
 */
contract TestFL2 is Test {
    address constant USDC_TOKEN = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant AAVE_POOL = address(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    address constant USDC_WHALE = address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);
    // $100M USDC
    uint256 constant BORROW_AMOUNT = 100_000_000 * 10**6;
    // Aave fee is 0.09% of the amount borrowed
    uint256 constant AAVE_FEE = 90_000 * 10**6;

    IERC20 usdc = IERC20(USDC_TOKEN);
    address deployer = makeAddr("deployer");
    
    FlashLoan flashLoan;

    function testFlashLoan() public {
        /** CODE YOUR SOLUTION HERE */
		// TODO: Get contract objects for relevant On-Chain contracts
		// TODO: Deploy Flash Loan contract
		// TODO: Send USDC to contract for fees
		// TODO: Execute successfully a Flash Loan of $100,000,000 (USDC)
    }
}
