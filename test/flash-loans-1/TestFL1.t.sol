// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/flash-loans-1/Pool.sol";
import "src/flash-loans-1/Receiver.sol";
import "src/flash-loans-1/GreedyReceiver.sol";

/**
 * @dev run "forge test -vvv --match-contract FL1"
 */
contract TestFL1 is Test {
    uint256 constant POOL_BALANCE = 1000 ether;
    address deployer = makeAddr("deployer");
    address user = makeAddr("user");

    Pool pool;

    function setUp() public {
        /**
         * SETUP, DON'T CHANGE
         */
        vm.deal(deployer, POOL_BALANCE);
        vm.prank(deployer);
        pool = new Pool{value: POOL_BALANCE}();
    }

    function testPool() public {
        vm.startPrank(user);

        vm.expectRevert("Not Enough ETH");
        pool.flashLoan(POOL_BALANCE + 1);
    }

    function testReceiver() public {
        vm.startPrank(user);
        Receiver receiver = new Receiver(address(pool));
        vm.deal(address(receiver), 1 ether);
        receiver.flashLoan(POOL_BALANCE);
    }

    function testGreedyReceiver() public {
        vm.startPrank(user);
        GreedyReceiver greedyReceiver = new GreedyReceiver(address(pool));
        vm.deal(address(greedyReceiver), 1 ether);

        vm.expectRevert("Flash Loan + fee not paid");
        greedyReceiver.flashLoan(POOL_BALANCE);
    }
}
