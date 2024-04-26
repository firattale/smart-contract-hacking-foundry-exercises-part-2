// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./ISecretDoor.sol";

/**
 * @dev run "forge test -vvv --fork-url sepolia --fork-block-number 5781872 --match-contract SOCD2"
 */
contract TestSOCD2 is Test {
    address constant SECRET_DOOR = address(0x5f83683A4DB0d73CA94046A85409097e459dE9de);
    address muggle = makeAddr("muggle");

    function testContract() public {
        /**
         * SETUP, DON'T CHANGE
         */
        ISecretDoor secretDoor = ISecretDoor(SECRET_DOOR);
        assertTrue(secretDoor.isLocked());

        /**
         * CODE YOUR SOLUTION HERE
         */
        bytes32 key = hex"454e5f425559554b5f46454e4552424148434500000000000000000000000000";
        secretDoor.unlockDoor(key);

        // assertTrue(secretDoor.unlockDoor(bytes32(abi.encodePacked("EN_BUYUK_FENERBAHCE"))));

        /**
         * SUCCESS CONDITIONS
         */
        assertFalse(secretDoor.isLocked());
    }
}
