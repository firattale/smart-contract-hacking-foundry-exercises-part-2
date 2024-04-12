// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/flash-loans-3/FlashSwap.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 15969633 --match-contract FL3"
 */
contract TestFL3 is Test {
    address constant USDC_TOKEN = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant USDC_WETH_PAIR = address(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    address constant USDC_WHALE = address(0x8e5dEdeAEb2EC54d0508973a0Fccd1754586974A);
    // $40M USDC
    uint256 constant BORROW_AMOUNT = 40_000_000 * 10**6;
    // Uniswap V2 fee is 0.3% which is $1.2M USDC
    uint256 constant UNISWAP_FEE = (BORROW_AMOUNT * 3) / 997 + 1;

    address deployer = makeAddr("deployer");
    
    FlashSwap flashSwap;

    function testFlashLoan() public {
        /** CODE YOUR SOLUTION HERE */
		// TODO: Get contract objects for relevant On-Chain contracts
		// TODO: Deploy Flash Swap contract
		// TODO: Send USDC to contract for fees
		// TODO: Execute successfully a Flash Swap of $40,000,000 (USDC)
        // TODO: Assert that fee was paid
    }
}
