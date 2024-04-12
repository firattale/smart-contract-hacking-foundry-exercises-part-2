# Replay Attack Exercise 1

## Intro

You withdrew 1 ETH from a centralized exchange to your wallet.

When you looked at the withdrawal transaction, you realized that it was from a multi-signature wallet smart contract.

Looking at the transaction, you noticed that two signatures were sent to the function:

Signature 1: 
```
{
  r: '0x1ddabf42460a80d2780a214aeec06787c1feb8046f4a88662db254e1ea1c15db',
  s: '0x1ddb0931fa6572af9ea5bab4c7afd0779a095beb68a9ca160c8b23647d63f7f9',
  v: 27,
}
```

Signature 2:
```
{
  r: '0xada7024b0ac3b997b1d05eedf4ba6020f1fdc92eaae47c2e9c6ec354ec86b075',
  s: '0x541172db522d0cc2ef6c651c8ef67b9f8fb858b394e239d8d1507e58356f787c',
  v: 27,
}
```

There's 100 ETH in this wallet right now. Can you get it all?

## Accounts
* 0 - Deployer & Signer 1
* 1 - Signer 2
* 2 - Attacker (You)

## Tasks

### Task 1
Drain all the MultiSig wallet ETH!

### Task 2
Make sure the MultiSig wallet is secured so that future attacks won't be possible.

Test the attack and make sure it failed, you may change the `before` section for this task.