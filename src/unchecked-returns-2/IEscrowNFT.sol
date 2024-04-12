// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IEscrowNFT is IERC721 {
    function tokenDetails(uint256) external view returns (uint256, uint256);
}
