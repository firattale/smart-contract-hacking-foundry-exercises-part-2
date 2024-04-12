// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./ISecretDoor.sol";

/**
 * @dev run "forge test -vvv --fork-url goerli --fork-block-number 8660077 --match-contract SOCD2"
 */
contract TestSOCD2 is Test {
    address constant SECRET_DOOR = address(0x148f340701D3Ff95c7aA0491f5497709861Ca27D);
    address muggle = makeAddr("muggle");

    function testContract() public {
        /** SETUP, DON'T CHANGE */

        ISecretDoor secretDoor = ISecretDoor(SECRET_DOOR);
        assertTrue(secretDoor.isLocked());

        /** CODE YOUR SOLUTION HERE */
        

        /** SUCCESS CONDITIONS */
        assertFalse(secretDoor.isLocked());
    }
}