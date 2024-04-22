// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Signature.sol";

/**
 * @title MultiSignatureWallet
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract SecuredMultiSignatureWallet {
    using Address for address payable;

    address[2] public signatories;

    mapping(bytes32 => bool) usedSignatures;

    constructor(address[2] memory _signatories) {
        signatories = _signatories;
    }

    function transfer(address to, uint256 amount, Signature[2] memory signatures) external {
        bytes32 sig1 = keccak256(abi.encodePacked(signatures[0].v, signatures[0].r, signatures[0].s));
        bytes32 sig2 = keccak256(abi.encodePacked(signatures[1].v, signatures[1].r, signatures[1].s));

        require(usedSignatures[sig1] == false && usedSignatures[sig2] == false, "one of the signtures were used");

        // Authenticity check
        require(_verifySignature(to, amount, signatures[0]) == signatories[0], "Access restricted");
        require(_verifySignature(to, amount, signatures[1]) == signatories[1], "Access restricted");

        usedSignatures[sig1] = true;
        usedSignatures[sig2] = true;

        payable(to).sendValue(amount);
    }

    function _verifySignature(address to, uint256 amount, Signature memory signature)
        internal
        pure
        returns (address signer)
    {
        // 52 = message byte length
        string memory header = "\x19Ethereum Signed Message:\n52";

        bytes32 messageHash = keccak256(abi.encodePacked(header, to, amount));

        // Perform the elliptic curve recover operation
        return ecrecover(messageHash, signature.v, signature.r, signature.s);
    }

    receive() external payable {}
}
