// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./ISecretDoor.sol";

/**
 * @dev run "forge test -vvv --fork-url sepolia --fork-block-number 5781872 --match-contract SOCD2"
 */
// storage 0 is address private _owner from Ownable
// storage 1 is uint256 private _status from ReentrancyGuard
// storage 2 is  bool public isLocked and uint8 private doorNumber from contract combined
// storage 3 is bytes32 private doorOwnerName from contract
// storage 4 is bytes32 private secretSpell from contract

//  cast storage 0x5f83683A4DB0d73CA94046A85409097e459dE9de --rpc-url sepolia 4

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
