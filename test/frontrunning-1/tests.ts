import { ethers } from 'hardhat';
import { expect } from 'chai';
import { BigNumber } from '@ethersproject/bignumber';
import { SignerWithAddress } from '@nomicfoundation/hardhat-ethers/signers';
import { FindMe } from '../../typechain-types';

const { provider, deployContract, getSigners, parseEther, parseUnits } = ethers;

/**
 * @dev run "npx hardhat test test/frontrunning-1/tests.ts"
 */
describe('Frontrunning Attack Exercise 1', function () {
	let deployer: SignerWithAddress, user: SignerWithAddress, attacker: SignerWithAddress;

	let attackerInitialBalance: bigint;

	let findMe: FindMe;

	before(async function () {
		/** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

		[deployer, user, attacker] = await getSigners();
		attackerInitialBalance = await provider.getBalance(attacker.address);

		findMe = await deployContract('FindMe', {
			value: parseEther('10'),
		});
		await provider.send('evm_mine', []);

		const obfuscatedString = atob('RXRoZXJldW0=');
		await findMe.connect(user).claim(obfuscatedString);
	});

	it('Exploit', async function () {
		/** CODE YOUR SOLUTION HERE */

    // TODO: Get all the tx's in the mempool

    // TODO: Find the tx that is sending eth to the FindMe contract
    
    // TODO: Send the same tx with more gas
    
	});

	after(async function () {
		// Mine all the transactions
		await provider.send('evm_mine', []);

		// Check if the attacker have in his balance at leat 9.9 more eth than what he had before
		const attackerBalance = await provider.getBalance(attacker.address);
		expect(attackerBalance).is.gt(attackerInitialBalance + parseEther('9.9'));
	});
});
