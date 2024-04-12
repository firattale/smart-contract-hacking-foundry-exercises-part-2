// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/money-markets-2/CompoundUser.sol";
import "src/money-markets-2/CompoundInterfaces.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 16776127 --match-contract MM2"
 */
contract TestMM2 is Test {
    address constant COMPTROLLER = address(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    address constant USDC_TOKEN = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant DAI_TOKEN = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant CUSDC_TOKEN = address(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    address constant CDAI_TOKEN = address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    address constant WHALE_USDC = address(0xF977814e90dA44bFA03b6295A0616a897441aceC);

    uint256 constant USER_USDC_BALANCE = 100_000 * 10 ** 6;
    uint256 constant AMOUNT_TO_DEPOSIT = 1_000 * 10 ** 6;
    uint256 constant AMOUNT_TO_BORROW = 100 ether;

    CompoundUser sut;
    IComptroller comptroller = IComptroller(COMPTROLLER);
    IERC20 usdc = IERC20(USDC_TOKEN);
    IERC20 dai = IERC20(DAI_TOKEN);
    cERC20 cUsdc = cERC20(CUSDC_TOKEN);
    cERC20 cDai = cERC20(CDAI_TOKEN);

    address immutable user = makeAddr("User");

    function setUp() public {
        /**
         * SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
         */
        vm.label(COMPTROLLER, "COMPTROLLER");
        vm.label(USDC_TOKEN, "USDC_TOKEN");
        vm.label(DAI_TOKEN, "DAI_TOKEN");
        vm.label(CUSDC_TOKEN, "CUSDC_TOKEN");
        vm.label(CDAI_TOKEN, "CDAI_TOKEN");
        vm.label(WHALE_USDC, "WHALE_USDC");

        vm.prank(WHALE_USDC);
        assertTrue(usdc.transfer(user, USER_USDC_BALANCE));
        assertEq(dai.balanceOf(user), 0);
    }

    function testContract() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        // TODO: Deploy CompoundUser.sol smart contract
        
        // TODO: Complete all the following tests using your deployed smart contract
        // TODO: Deposit 1000 USDC to compound
        
        // TODO: Validate that the depositedAmount state var was changed
        
        // TODO: Store the cUSDC tokens that were minted to the compoundUser contract in `cUSDCBalanceBefore`
        
        // TODO: Validate that your contract received cUSDC tokens (receipt tokens)
        
        // TODO: Allow USDC as collateral
        
        // TODO: Borrow 100 DAI against the deposited USDC
        
        // TODO: Validate that the borrowedAmount state var was changed
        
        // TODO: Validate that the user received the DAI Tokens
        
        // TODO: Repay all the borrowed DAI
        
        // TODO: Validate that the borrowedAmount state var was changed
        
        // TODO: Validate that the user doesn't own the DAI tokens
        
        // TODO: Withdraw all your USDC
        
        // TODO: Validate that the depositedAmount state var was changed
        
        // TODO: Validate that the user got the USDC tokens back
        
        // TODO: Validate that the majority of the cUSDC tokens (99.9%) were burned, and the contract doesn't own them
        // NOTE: There are still some cUSDC tokens left, since we accumelated positive interest
        
    }
}
