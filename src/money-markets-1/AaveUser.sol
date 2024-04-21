// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AaveInterfaces.sol";

contract AaveUser is Ownable {
    // TODO: Complete state variables
    IPool aave_pool;
    IERC20 usdc;
    IERC20 dai;

    uint256 public depositedAmount;
    uint256 public borrowedAmount;
    // TODO: Complete the constructor

    constructor(address _pool, address _usdc, address _dai) {
        aave_pool = IPool(_pool);
        usdc = IERC20(_usdc);
        dai = IERC20(_dai);
    }

    // Deposit USDC in AAVE Pool
    function depositUSDC(uint256 _amount) external onlyOwner {
        // TODO: Implement this function

        // TODO: Update depositedamount state var
        depositedAmount += _amount;
        // TODO: Transfer from the sender the USDC to this contract
        usdc.transferFrom(owner(), address(this), _amount);
        usdc.approve(address(aave_pool), _amount);

        // TODO: Supply USDC to aavePool Pool
        aave_pool.supply(address(usdc), _amount, address(this), 0);
    }

    // Withdraw USDC
    function withdrawUSDC(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        // TODO: Revert if the user is trying to withdraw more than the deposited amount
        require(_amount <= depositedAmount, "Amount is higher than the deposited amount");
        // TODO: Update depositedamount state var
        depositedAmount -= _amount;
        // TODO: Withdraw the USDC tokens, send them directly to the user
        aave_pool.withdraw(address(usdc), _amount, owner());
    }

    // Borrow DAI From aave, send DAI to the user (msg.sender)
    function borrowDAI(uint256 _amount) external onlyOwner {
        // TODO: Implement this function

        // TODO: Update borrowedAmmount state var
        borrowedAmount += _amount;
        // TODO: Borrow the DAI tokens in variable interest mode
        aave_pool.borrow(address(dai), _amount, 2, 0, address(this));
        // TODO: Transfer DAI token to the user
        dai.transfer(owner(), _amount);
    }

    // Repay the borrowed DAI to AAVE
    function repayDAI(uint256 _amount) external onlyOwner {
        // TODO: Implement this function
        // TODO: Revert if the user is trying to repay more tokens that he borrowed
        require(_amount <= borrowedAmount, "You are trying to repay more than you borrowed");
        // TODO: Update borrowedAmmount state var
        borrowedAmount -= _amount;
        uint256 daiAmount = dai.balanceOf(owner());
        // TODO: Transfer the DAI tokens from the user to this contract
        dai.transferFrom(owner(), address(this), daiAmount);
        // TODO: Approve AAVE Pool to spend the DAI tokens
        dai.approve(address(aave_pool), daiAmount);
        // TODO: Repay the loan
        aave_pool.repay(address(dai), daiAmount, 2, address(this));
    }
}
