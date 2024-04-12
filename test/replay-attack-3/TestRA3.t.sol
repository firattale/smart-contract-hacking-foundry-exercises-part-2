// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "src/replay-attack-3/RedHawksVIP.sol";

/**
 * @dev run "forge test -vvv --match-contract RA3"
 *
 * Note: 'Stolen' signature bytes are different from the Hardhat version of this exercise because
 * different addresses were used to create the signatures.
 */
contract TestRA3 is Test {
    using ECDSA for bytes32;
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");

    address deployer;
    uint256 deployerKey;
    address vouchersSigner;
    uint256 signerKey;
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    RedHawksVIP redHawks;

    function setUp() public {
        (deployer, deployerKey) = makeAddrAndKey("deployer");
        (vouchersSigner, signerKey) = makeAddrAndKey("vouchersSigner");
        redHawks = new RedHawksVIP(vouchersSigner);

        bytes32 dataHash = _hashTypedDataV4(
            keccak256(abi.encode(
                keccak256("VoucherData(uint256 amountOfTickets,string password)"),
                2,
                keccak256(bytes("RedHawksRulzzz133"))
            ))
        );

        // Create signatures
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, dataHash);
        bytes memory validSignature = abi.encodePacked(r, s, v); // Note: Order here should be different from line above


        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(deployerKey, dataHash);
        bytes memory invalidSignature = abi.encodePacked(r2, s2, v2);

        vm.startPrank(user);

        // Trying to sign with invalid signer
        vm.expectRevert("Invalid voucher");
        redHawks.mint(2, "RedHawksRulzzz133", invalidSignature);

        // Trying to sign with invalid data (password)
        vm.expectRevert("Invalid voucher");
        redHawks.mint(2, "wrongPassword", validSignature);

        // Mint 2 NFTs with valid data and signature
        redHawks.mint(2, "RedHawksRulzzz133", validSignature);

        // Try using voucher twice
        vm.expectRevert("Voucher used");
        redHawks.mint(2, "RedHawksRulzzz133", validSignature);

        vm.stopPrank();
    }

    function testRedHawks() public {
        /** CODE YOUR SOLUTION HERE */

        /** SUCCESS CONDITIONS */

		// Attacker got all 178 VIP Membership Tickets
        assertEq(redHawks.balanceOf(attacker), 178);
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        bytes32 domainSeparatorHash = keccak256(abi.encode(_TYPE_HASH, block.chainid, address(redHawks)));
        return domainSeparatorHash;
    }

    function _hashTypedDataV4(
        bytes32 structHash
    ) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}
