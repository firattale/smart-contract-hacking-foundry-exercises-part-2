// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/money-markets-1/AaveUser.sol";
import "src/money-markets-1/AaveInterfaces.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 16776127 --match-contract MM1"
 */
contract TestMM1 is Test {
    address constant AAVE_V3_POOL = address(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);
    address constant USDC_TOKEN = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant DAI_TOKEN = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant USDC_WHALE = address(0xF977814e90dA44bFA03b6295A0616a897441aceC);
    // AAVE USDC Receipt Token
	address constant A_USDC = address(0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c);
	// AAVE DAI Variable Debt Token
	address constant VARIABLE_DEBT_DAI = address(0xcF8d0c70c850859266f5C338b38F9D663181C314);

    uint256 constant USER_USDC_BALANCE = 100000 * 10**6;
    uint256 constant AMOUNT_TO_DEPOSIT = 1000 * 10**6;
    uint256 constant AMOUNT_TO_BORROW = 100 ether;

    AaveUser sut;
    IERC20 usdc;
    IERC20 dai;
    IERC20 aUSDC;
    IERC20 debtDAI;
    address user = makeAddr("user");

    function setUp() public {
        /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.label(AAVE_V3_POOL, "AAVE_V3_POOL");
        vm.label(USDC_TOKEN, "USDC_TOKEN");
        vm.label(DAI_TOKEN, "DAI_TOKEN");
        vm.label(USDC_WHALE, "USDC_WHALE");
        vm.label(A_USDC, "A_USDC");
        vm.label(VARIABLE_DEBT_DAI, "VARIABLE_DEBT_DAI");
        
        usdc = IERC20(USDC_TOKEN);
        dai = IERC20(DAI_TOKEN);
        aUSDC = IERC20(A_USDC);
        debtDAI = IERC20(VARIABLE_DEBT_DAI);

        vm.prank(USDC_WHALE);
        usdc.transfer(user, USER_USDC_BALANCE);
        assertEq(usdc.balanceOf(user), USER_USDC_BALANCE);
    }

    function testContract() public {
        /** CODE YOUR SOLUTION HERE */
		// TODO: Deploy AaveUser contract
        
		// TODO: Appove and deposit 1000 USDC tokens

		// TODO: Validate that the depositedAmount state var was changed

		// TODO: Validate that your contract received the aUSDC tokens (receipt tokens)

		// TODO: borrow 100 DAI tokens

		// TODO: Validate that the borrowedAmount state var was changed

		// TODO: Validate that the user received the DAI Tokens

		// TODO: Validate that your contract received the DAI variable debt tokens
        
		// TODO: Repay all the DAI

		// TODO: Validate that the borrowedAmount state var was changed

		// TODO: Validate that the user doesn't own the DAI tokens

		// TODO: Validate that your contract own much less DAI Variable debt tokens (less then 0.1% of borrowed amount)
		// Note: The contract still supposed to own some becuase of negative interest

		// TODO: Withdraw all your USDC

		// TODO: Validate that the depositedAmount state var was changed

		// TODO: Validate that the user got the USDC tokens back

		// TODO: Validate that your contract own much less aUSDC receipt tokens (less then 0.1% of deposited amount)
		// Note: The contract still supposed to own some becuase of the positive interest
    }
}