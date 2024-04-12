// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/utils/DummyERC20.sol";
import "src/call-attacks-3/CryptoKeeper.sol";
import "src/call-attacks-3/ICryptoKeeper.sol";
import "src/call-attacks-3/CryptoKeeperFactory.sol";

/**
 * @dev run "forge test -vvv --match-contract CA3"
 */
contract TestCA3 is Test {

    address deployer = makeAddr("deployer");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address attacker = makeAddr("attacker");

    DummyERC20 token;
    CryptoKeeper cryptoKeeperTemplate;
	CryptoKeeperFactory cryptoKeeperFactory ;
	CryptoKeeper cryptoKeeper1;
    CryptoKeeper cryptoKeeper2; 
    CryptoKeeper cryptoKeeper3;

    uint256 attackerInitialBalance;
    uint8 constant CALL_OPERATION = 1;
    
    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.startPrank(deployer);

        // Deploy ERC20 Token
        token = new DummyERC20("DummyERC20", "DToken", 1000 ether);
        token.name(); // To keep startPrank happy

        // Deploy Template and Factory
        cryptoKeeperTemplate = new CryptoKeeper();
        cryptoKeeperFactory = new CryptoKeeperFactory(deployer, address(cryptoKeeperTemplate));
        address[] memory operators = new address[](1);

        // User1 creating CryptoKeepers
        vm.startPrank(user1);
        operators[0] = user1;
        bytes32 user1Salt = keccak256(abi.encodePacked(user1));
        cryptoKeeper1 = CryptoKeeper(payable(cryptoKeeperFactory.createCryptoKeeper(user1Salt, operators)));

        // User2 creating CryptoKeeperscreateCryptoKeeper
        vm.startPrank(user2);
        operators[0] = user2;
        bytes32 user2Salt = keccak256(abi.encodePacked(user2));
        cryptoKeeper2 = CryptoKeeper(payable(cryptoKeeperFactory.createCryptoKeeper(user2Salt, operators)));

        // User3 creating CryptoKeepers
        vm.startPrank(user3);
        operators[0] = user3;
        bytes32 user3Salt = keccak256(abi.encodePacked(user3));
        cryptoKeeper3 = CryptoKeeper(payable(cryptoKeeperFactory.createCryptoKeeper(user3Salt, operators)));

        // Users load their cryptoKeeper with some ETH
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);
        (bool success, ) = address(cryptoKeeper1).call{value: 10 ether}("");
        assertTrue(success);

        vm.deal(user2, 10 ether);
        vm.startPrank(user2);
        (success, ) = address(cryptoKeeper2).call{value: 10 ether}("");
        assertTrue(success);

        vm.deal(user3, 10 ether);
        vm.startPrank(user3);
        (success, ) = address(cryptoKeeper3).call{value: 10 ether}("");
        assertTrue(success);

        // cryptoKeeper operation works
        vm.startPrank(user1);
        cryptoKeeper1.executeWithValue(user2, "0x0", 1 ether);
        vm.startPrank(user2);
        cryptoKeeper2.executeWithValue(user1, "0x0", 1 ether);
        vm.startPrank(user3);
        cryptoKeeper3.executeWithValue(user1, "0x0", 1 ether);

        // Only operator can manage wallet
		
        // addOperator fails
        vm.startPrank(user2);
        vm.expectRevert("Not an operator");
        cryptoKeeper1.addOperator(user2);

        // executeWithValue fails
        vm.expectRevert("Not an operator");
        cryptoKeeper1.executeWithValue(user2, "0x", 1 ether);

        // execute fails
        vm.expectRevert("Not an operator");
        bytes memory tokenCallData = abi.encodeWithSignature("balanceOf(address)", deployer);
        cryptoKeeper1.execute(address(token), tokenCallData, CALL_OPERATION);

        attackerInitialBalance = attacker.balance;
    }

    function testCallAttack3() public {
        /** CODE YOUR SOLUTION HERE */
        
        /** SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE */

        // Attacker suppose to steal all the ETH from the Crypto Keepers
        assertEq(address(cryptoKeeper1).balance, 0);
        assertEq(address(cryptoKeeper2).balance, 0);
        assertEq(address(cryptoKeeper3).balance, 0);
        assertEq(attacker.balance, attackerInitialBalance + 30 ether - 3 ether); // initial balance + total eth - 3 eth sent to users in setup
    }
}