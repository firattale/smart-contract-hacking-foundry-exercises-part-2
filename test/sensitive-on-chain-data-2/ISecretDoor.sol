// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Interface for the SecredDoor contract.
// Part of the task solution.
interface ISecretDoor {
    function isLocked() external view returns (bool);
    function unlockDoor(bytes32) external returns (bool);
}