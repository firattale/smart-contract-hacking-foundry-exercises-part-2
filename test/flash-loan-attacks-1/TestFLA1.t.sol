// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/flash-loan-attacks-1/Pool.sol";
import "src/flash-loan-attacks-1/Token.sol";

/**
 * @dev run "forge test -vvv --match-contract FLA1"
 */
contract TestFLA1 is Test {

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    uint256 constant POOL_TOKENS = 100_000_000 ether; // 100M pool tokens
    Token token;
    Pool pool;

    function setUp() public {
        /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

		// Deploy token & pool
        vm.startPrank(deployer);
        token = new Token();
        pool = new Pool(address(token));

		// Transfer tokens to pool
        token.transfer(address(pool), POOL_TOKENS);

		// Pool should have 100M, attacker should have 0 tokens
        assertEq(token.balanceOf(address(pool)), POOL_TOKENS);
        assertEq(token.balanceOf(attacker), 0);
    }

    function testFlashLoanAttack() public {
        /** CODE YOUR SOLUTION HERE */

        /** SUCCESS CONDITIONS */

		// Attacker successfully stole all tokens form the pool
        assertEq(token.balanceOf(address(pool)), 0);
        assertEq(token.balanceOf(attacker), POOL_TOKENS);
    }
}
