// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDAOToken is IERC20 {

    function snapshot() external returns (uint256 lastSnapshotId);

    function getBalanceAtSnapshot(
        address account,
        uint256 snapshotID
    ) external view returns (uint256);

    function getTotalSupplyAtSnapshot(
        uint256 snapshotID
    ) external view returns (uint256);
}
