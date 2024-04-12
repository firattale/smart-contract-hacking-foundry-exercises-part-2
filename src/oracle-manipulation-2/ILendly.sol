// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ILendly {
    function deposit(address _token, uint256 _amount) external;
    function withdraw(address _token, uint256 _amount) external;
    function borrow(address _token, uint256 _amount) external;
    function repay(address _token, uint256 _amount) external;
}