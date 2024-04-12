// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/oracle-manipulation-2/Lendly.sol";
import "src/interfaces/IWETH9.sol";

/**
 * @dev run "forge test -vvv --fork-url mainnet --fork-block-number 15969633 --match-contract OM2"
 */
contract TestOM2 is Test {
    
    // Addresses
    address PAIR_ADDRESS = address(0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11); // DAI/WETH
	address DAI_ADDRESS = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI
    address WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH
	address IMPERSONATED_ACCOUNT_ADDRESS = address(0xF977814e90dA44bFA03b6295A0616a897441aceC); // Binance Hot Wallet

	// Amounts
    uint256 constant WETH_LIQUIDITY = 180 ether; // 180 ETH
	uint256 constant DAI_LIQUIDITY = 270_000 ether; // 270K USD

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    
    Lendly lendly;
    // LendlySecured lendly;

    IWETH9 weth;
    IERC20 dai;
    
    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

        // Attacker starts with 1 ETH
        vm.deal(attacker, 1 ether);
        assertEq(attacker.balance, 1 ether);
        
        // Deploy Lendly with DAI/WETH contract
        vm.startPrank(deployer);
        lendly = new Lendly(PAIR_ADDRESS);
        // lendly = new LendlySecured(PAIR_ADDRESS);

        // Load Tokens contract
        weth = IWETH9(WETH_ADDRESS);
        vm.label(WETH_ADDRESS, "WETH");
        dai = IERC20(DAI_ADDRESS);
        vm.label(DAI_ADDRESS, "DAI");

        // Convert ETH to WETH
        vm.deal(deployer, WETH_LIQUIDITY);
        weth.deposit{value: WETH_LIQUIDITY}();
        assertEq(weth.balanceOf(deployer), WETH_LIQUIDITY);

        // Deposit WETH from Deployer to Lendly
        weth.approve(address(lendly), WETH_LIQUIDITY);
        lendly.deposit(WETH_ADDRESS, WETH_LIQUIDITY);

        // WETH despoit succeded
        assertEq(weth.balanceOf(address(lendly)), WETH_LIQUIDITY);
        assertEq(lendly.deposited(address(weth), deployer), WETH_LIQUIDITY);

        // Depsit DAI on Lendly (from Binance hot wallet)
        vm.startPrank(IMPERSONATED_ACCOUNT_ADDRESS);
        dai.approve(address(lendly), DAI_LIQUIDITY);
        lendly.deposit(address(dai), DAI_LIQUIDITY);

        // DAI despoit succeded
        assertEq(dai.balanceOf(address(lendly)), DAI_LIQUIDITY);
        assertEq(lendly.deposited(address(dai), IMPERSONATED_ACCOUNT_ADDRESS), DAI_LIQUIDITY);

        // Didn't deposit WETH so can't borrow DAI
        vm.expectRevert();
        lendly.borrow(address(dai), DAI_LIQUIDITY);

        // WETH depositor can borrow some DAI
        vm.startPrank(deployer);
        lendly.borrow(address(dai), 100 ether);
    }

    function testOracle2Exploit() public {
        /** CODE YOUR SOLUTION HERE */

        /** SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE */

        // Protocol Liquidity
        console.log('Lendly DAI balance: ', dai.balanceOf(address(lendly)));
		console.log('Lendly WETH balance: ', weth.balanceOf(address(lendly)));

		console.log('Attacker DAI balance: ', dai.balanceOf(address(attacker)));
		console.log('Attacker WETH balance: ', weth.balanceOf(address(attacker)));

		// Pool liquidity should be at least -95%
        assertLt(dai.balanceOf(address(lendly)), (DAI_LIQUIDITY * 5) / 100);
        assertLt(weth.balanceOf(address(lendly)), (WETH_LIQUIDITY * 5) / 100);

		// Attacker stole the liquidity - at least +88%
        assertGt(dai.balanceOf(attacker), (DAI_LIQUIDITY * 88) / 100);
        assertGt(weth.balanceOf(attacker), (WETH_LIQUIDITY * 88) / 100);
    }
}