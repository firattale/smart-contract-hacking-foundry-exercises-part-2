// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "src/dos-4/GalacticGorillas.sol";

/**
 * @dev run "forge test -vvv --match-contract DOS4"
 */
contract TestDOS4 is Test {

    uint256 constant MINT_PRICE = 1 ether;

    address deployer = makeAddr("deployer");
    address user = makeAddr("user");
    address attacker = makeAddr("attacker");

    GalacticGorillas nft;

    function setUp() public {
        /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
        vm.deal(attacker, 2.5 ether);
        vm.deal(user, 100 ether);

        vm.startPrank(deployer);
        nft = new GalacticGorillas();
        vm.stopPrank();
    }
    
    function testSuccessMinting() public {
        uint256 deployerBalanceBefore = address(deployer).balance;
        
        vm.startPrank(user);
        nft.mint{value: MINT_PRICE * 2}(2);

        assertEq(nft.balanceOf(user), 2);
        assertEq(nft.ownerOf(1), user);
        assertEq(nft.ownerOf(2), user);

        assertEq(address(deployer).balance, deployerBalanceBefore + MINT_PRICE * 2);
    }

    function testMintingFailure() public {
        vm.startPrank(user);

        vm.expectRevert("wrong _mintAmount");
        nft.mint(20);

        vm.expectRevert("not enough ETH");
        nft.mint(1);

        nft.mint{value: MINT_PRICE * 2 }(2);
        vm.expectRevert("exceeded MAX_PER_WALLET");
        nft.mint{value: MINT_PRICE * 4 }(4);
    }

    function testPause() public {
        // Try pausing without being owner
        vm.startPrank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.pause(true);

        // Pause and try minting
        vm.startPrank(deployer);
        nft.pause(true);
        vm.expectRevert("contract is paused");
        vm.startPrank(user);
        nft.mint{value: MINT_PRICE * 2 }(2);

        // Unpause and try minting
        vm.startPrank(deployer);
        nft.pause(false);
        vm.startPrank(user);
        nft.mint{value: MINT_PRICE * 1 }(1);
        assertEq(nft.balanceOf(user), 1);
    }

    function testDosAttack() public {
        /** SETUP, DON'T CHANGE */
        vm.startPrank(user);
        nft.mint{value: MINT_PRICE * 3}(3);

        /** CODE YOUR SOLUTION HERE */        

        /** SUCCESS CONDITIONS */
        vm.startPrank(user);
        vm.expectRevert();
        // User can't mint nfts even though he is eligable for 2 additional mints
        nft.mint{value: MINT_PRICE}(1);
    }
}
