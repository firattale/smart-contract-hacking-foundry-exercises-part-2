// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./GreedyReceiver.sol";

/**
 * @title Receiver
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract Receiver {
    IPool pool;

    constructor(address _poolAddress) {
        pool = IPool(_poolAddress);
    }

    // TODO: Implement Receiver logic (Receiving a loan and paying it back)

    // TODO: Complete this function
    function flashLoan(uint256 _amount) external {
        pool.flashLoan(_amount);
    }

    // TODO: Complete getETH() payable function

    function getETH() external payable {
        // Do something with the ETH first and then send
        (bool sent,) = address(pool).call{value: msg.value + 100 wei}("");
        require(sent, "ETH Transfer to Pool Failed");
    }
}
