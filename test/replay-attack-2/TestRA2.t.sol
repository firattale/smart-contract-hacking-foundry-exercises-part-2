// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/replay-attack-2/SecuredRealtySale.sol";
import "src/replay-attack-2/RealtyToken.sol";
import {AttackRealtySale} from "src/replay-attack-2/AttackRealtySale.sol";
import "src/replay-attack-2/Structs.sol";

/**
 * @dev run "forge test -vvv --match-contract RA2"
 */
contract TestRA2 is Test {
    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address attacker = makeAddr("attacker");

    // Note: Replace type with SecuredRealtySale to check more secure implementation
    SecuredRealtySale realtySale;
    RealtyToken realtyToken;

    function setUp() public {
        vm.deal(attacker, 1 ether);
        vm.startPrank(deployer);
        realtySale = new SecuredRealtySale();
        realtyToken = RealtyToken(realtySale.getTokenContract());

        // Buy without sending ETH reverts
        vm.startPrank(user1);
        vm.expectRevert();
        realtySale.buy{value: 1 ether}();

        // Give users ether
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);

        // Some users buy tokens (1 ETH each share)
        realtySale.buy{value: 1 ether}();
        vm.startPrank(user2);
        realtySale.buy{value: 1 ether}();

        // 2 ETH in contract
        assertEq(address(realtySale).balance, 2 ether);

        // Buyer got their share token
        assertEq(realtyToken.balanceOf(user1), 1);
        assertEq(realtyToken.balanceOf(user2), 1);
    }

    function testRealtySale() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        AttackRealtySale attackRealtySale = new AttackRealtySale(address(realtySale));
        for (uint256 index = 0; index < 98; index++) {
            attackRealtySale.attack();
        }

        /**
         * SUCCESS CONDITIONS
         */

        // // Attacker bought all 98 shares
        assertEq(realtyToken.balanceOf(attacker), 98);

        // // No more shares left :(
        assertEq(realtyToken.maxSupply(), realtyToken.lastTokenID());
    }
}
