// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title MultiSigSafe
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract SecuredMultiSigSafe {
    address[] public signers;
    uint8 public requiredApprovals;

    // To -> Amount -> Approvals
    mapping(address => mapping(uint256 => uint256)) public withdrawRequests;

    constructor(address[] memory _signers, uint8 _requiredApprovals) {
        requiredApprovals = _requiredApprovals;
        for (uint256 i = 0; i < _signers.length; i++) {
            signers.push(_signers[i]);
        }
    }

    function withdrawETH(address _to, uint256 _amount) external {
        uint256 approvals = withdrawRequests[_to][_amount];
        require(approvals >= requiredApprovals, "Not enough approvals");

        withdrawRequests[_to][_amount] = 0;
        // payable(_to).send(_amount);
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Transfer Eth Failed!");
    }

    receive() external payable {}
}
