// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/dao-attack-3/DAOToken.sol";
import "src/dao-attack-3/Governance.sol";
import "src/dao-attack-3/LendingPool.sol";
import "src/dao-attack-3/Treasury.sol";
import "src/dao-attack-3/AttackDAO.sol";

/**
 * @dev run "forge test -vvv --match-contract DAO3"
 */
contract TestDAO3 is Test {
    // DAO Tokens
    uint256 constant DEPLOYER_TOKENS = 2_500_000 ether; // 2.5M Tokens
    uint256 constant MEMBER_1_TOKENS = 500_000 ether; // 500K Tokens
    uint256 constant MEMBER_2_TOKENS = 1_000_000 ether; // 1M Tokens
    uint256 constant TOKENS_IN_POOL = 2_000_000 ether; // 2M Tokens

    // Treasury ETH
    uint256 constant ETH_IN_TREASURY = 1500 ether; // 1500 ETH

    DAOToken token;
    LendingPool pool;
    Treasury treasury;
    Governance governance;

    address deployer = makeAddr("deployer");
    address member1 = makeAddr("member1");
    address member2 = makeAddr("member2");
    address attacker = makeAddr("attacker");

    uint256 attackerInitialETHBalance;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        attackerInitialETHBalance = attacker.balance;

        // Deploy and Setup Contracts
        vm.startPrank(deployer);
        token = new DAOToken();
        pool = new LendingPool(address(token));
        treasury = new Treasury();
        governance = new Governance(address(token), address(treasury));

        treasury.setGovernance(address(governance));

        // ETH to Treasury
        vm.deal(address(treasury), ETH_IN_TREASURY);
        assertEq(address(treasury).balance, ETH_IN_TREASURY);

        // Mint tokens
        token.mint(deployer, DEPLOYER_TOKENS);
        token.mint(member1, MEMBER_1_TOKENS);
        token.mint(member2, MEMBER_2_TOKENS);
        token.mint(address(pool), TOKENS_IN_POOL);
    }

    function testGovernanceExploit() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        AttackDAO attackDAO =
            new AttackDAO(address(pool), address(token), address(governance), payable(address(treasury)));

        attackDAO.attack(token.balanceOf(address(pool)));

        /**
         * SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE
         */

        // No ETH left in treasury
        assertEq(address(treasury).balance, 0);

        // Attacker stole all ETH from the treasury
        assertGt(address(attacker).balance, attackerInitialETHBalance + ETH_IN_TREASURY - 0.2 ether);
    }
}
