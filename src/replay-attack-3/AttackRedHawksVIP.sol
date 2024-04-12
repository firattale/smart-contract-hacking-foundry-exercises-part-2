//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRedHawksVIP {
    //TODO: implement this
}

contract AttackRedHawksVIP is Ownable {
    address private redHawks;

    constructor(address _redHawks) {
        //TODO: save address in storage
    }

    function attack(uint16 i, uint16 j, string memory pass, bytes memory sig) public onlyOwner {
        //TODO: mint using the pass and sig
        //TODO: transfer both minted NFTs to the owner
        //NOTE: For NFT ids, you have to use the passed "i" & "j" values
    }
}
