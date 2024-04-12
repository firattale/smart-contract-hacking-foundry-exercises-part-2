// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/oracle-manipulation-1/GoldExchange.sol";
import "src/oracle-manipulation-1/GoldOracle.sol";
import "src/oracle-manipulation-1/GoldToken.sol";

/**
 * @dev run "forge test -vvv --match-contract OM1"
 */
contract TestOM1 is Test {
    address[] sources = new address[](3);

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    uint256 constant EXCHANGE_INITIAL_BALANCE = 1800 ether; 
    uint256 constant INITIAL_GOLD_PRICE = 1.5 ether; 
    
    GoldToken token;
	GoldOracle oracle;
	GoldExchange exchange;

    uint256 initialAttackerBalance;
    
    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

        // Set sources
        sources[0] = address(0x4aC89064Fa0d03De57f802feC722925b4502572A);
        sources[1] = address(0x96574c0392112CbEe134eb77e76A183d54A7c18f);
        sources[2] = address(0xA7804BB057EBB7D0c0a3C7F4B8710AE854525fd4);

        uint256[] memory initialPrices = new uint256[](3);
        initialPrices[0] = INITIAL_GOLD_PRICE;
        initialPrices[1] = INITIAL_GOLD_PRICE;
        initialPrices[2] = INITIAL_GOLD_PRICE;

        // Attacker starts with 1 ETH
        vm.deal(attacker, 1 ether);
        assertEq(attacker.balance, 1 ether);
        initialAttackerBalance = attacker.balance;

        // Sources starts with 10 ETH
        for (uint8 i = 0; i < sources.length; i++) {
            vm.deal(sources[i], 10 ether);
            assertEq(sources[i].balance, 10 ether);
        }

        // Deploy contracts
        token = new GoldToken();
        oracle = new GoldOracle(sources, initialPrices);
        exchange = new GoldExchange{value: EXCHANGE_INITIAL_BALANCE}(address(token), address(oracle));

        // Transfer token ownership to exchange
        token.transferOwnership(address(exchange));
    }

    function testOracle1Exploit() public {
        /** CODE YOUR SOLUTION HERE */


        /** SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE */

        // Exchange lost almost all ETH
        assertLe(address(exchange).balance, 0.1 ether);

		// Attacker's earned a lot of ETH on top of the exchange
        assertGt(attacker.balance, initialAttackerBalance + EXCHANGE_INITIAL_BALANCE - 0.2 ether);

		// Gold price shouldn't have changed
        assertEq(oracle.getPrice(), INITIAL_GOLD_PRICE);
    }
}