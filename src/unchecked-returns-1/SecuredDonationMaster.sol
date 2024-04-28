// SCH Course Copyright Policy (C): DO-NOT-SHARE-WITH-ANYONE
// https://smartcontractshacking.com/#copyright-policy
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/**
 * @title SecuredDonationMaster
 * @author JohnnyTime (https://smartcontractshacking.com)
 */
contract SecuredDonationMaster {
    uint256 public donationsNo = 1;

    struct Donation {
        uint256 id;
        address to;
        uint256 goal;
        uint256 donated;
    }

    mapping(uint256 => Donation) public donations;

    constructor() {}

    function newDonation(address _to, uint256 goal) external {
        require(_to != address(0), "Wrong _to");
        require(goal >= 0, "Wrong _goal");

        Donation memory donation = Donation(donationsNo, _to, goal, 0);
        donations[donationsNo] = donation;
        donationsNo += 1;
    }

    function donate(uint256 _donationId) external payable {
        require(_donationId < donationsNo, "Donation doesn't exist");

        Donation memory donation = donations[_donationId];
        require(msg.value + donation.donated <= donation.goal, "Goal reached, donation is closed");

        donation.donated += msg.value;
        donations[_donationId] = donation;

        // payable(donation.to).send(msg.value);
        (bool success,) = donation.to.call{value: msg.value}("");
        require(success, "ETH transfer failed!");
    }
}
