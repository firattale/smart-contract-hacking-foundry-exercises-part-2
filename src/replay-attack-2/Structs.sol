// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct SharePrice {
    uint256 expires; // Time which the price expires
    uint256 price; // Share Price in ETH
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}