// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Interface for the CrypticRaffle contract.
// Part of the task solution.
interface ICrypticRaffle {
    function PARTICIPIATION_PRICE() external view returns (uint256);
    function guessNumbers(uint8[3] calldata numbers) external payable;
    function newRaffle(uint8[3] calldata numbers) external;
}