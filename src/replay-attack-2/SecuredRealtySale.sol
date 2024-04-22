// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./RealtyToken.sol";
import "./Structs.sol";

/**
 * @title RealtySaleEIP712
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
abstract contract RealtySaleEIP712 is EIP712 {
    bytes32 public constant SHARE_PRICE_TYPEHASH = keccak256("SharePrice(uint256 expires,uint256 price)");

    function _hashSharePrice(SharePrice memory sharePrice) internal view returns (bytes32 hash) {
        return _hashTypedDataV4(keccak256(abi.encode(SHARE_PRICE_TYPEHASH, sharePrice.expires, sharePrice.price)));
    }
}

contract SecuredRealtySale is Ownable, RealtySaleEIP712 {
    RealtyToken public immutable shareToken;
    uint256 public constant INITAL_SHARE_PRICE = 1 ether;
    address private oracle;

    constructor() EIP712("RealtySale", "0.1") {
        shareToken = new RealtyToken();
    }

    function buy() external payable {
        _mintShare(msg.sender, INITAL_SHARE_PRICE);
    }

    function buyWithOracle(SharePrice calldata sharePrice, Signature calldata signature) external payable {
        _validateSharePrice(sharePrice, signature);
        _mintShare(msg.sender, sharePrice.price);
    }

    function _mintShare(address buyer, uint256 price) internal {
        require(msg.value == price, "not enough ETH");
        shareToken.mint(buyer);
    }

    function _recover(bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        return ecrecover(digest, v, r, s);
    }

    function getTokenContract() external view returns (address token) {
        return address(shareToken);
    }

    // @audit how can someone validate this price? and sharePrice would be null.
    // where does oracle sign the message?
    function _validateSharePrice(SharePrice calldata sharePrice, Signature calldata signature) internal view {
        require(sharePrice.expires > block.timestamp, "price too old!");

        //  @audit this can be copied in a smart contract
        bytes32 sharePriceHash = _hashSharePrice(sharePrice);
        // @audit if it is not valid, it might return address(0)
        address recovered = _recover(sharePriceHash, signature.v, signature.r, signature.s);

        require(recovered != address(0), "wrong signature provided");

        require(recovered == oracle, "Only oracle can sign prices");
    }
    // @audit oracle has not been set initially???

    function setOracle(address _oracle) external onlyOwner {
        oracle = _oracle;
    }

    function withdraw() external onlyOwner {
        (bool sent,) = owner().call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
