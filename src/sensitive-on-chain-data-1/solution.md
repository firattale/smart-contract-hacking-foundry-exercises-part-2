# Commands / Results
> Use this doc to write down the commands and their respective results when executed

# Task 1 - Retreiving General Information

**Retreive the chainID.**

```bash 
Command: cast chain-id
Chain-id = 56
```

**Retreive the last validated block number.**

``` bash
Command: cast block-number
Latest Block number = 38195491
```

# Task 2 - Retreiving Transaction and Block Information

**Get the transaction info for this tx hash `0x3f6da406747a55797a7f84173cbb243f4fd929d57326fdcfcf8d7ca55b75fe99.**

```bash
Command: cast tx 0x3f6da406747a55797a7f84173cbb243f4fd929d57326fdcfcf8d7ca55b75fe99
```

**Get the block timestamp and the miner address who validated the block of the transaction from the previous question.**

```bash
Command: cast block  25263862 -f timestamp
Timestamp: 1675173198
 ```

**For the same transaction, get the transaction input data and contract address that was called.**

```bash
Command: cast tx 0x3f6da406747a55797a7f84173cbb243f4fd929d57326fdcfcf8d7ca55b75fe99 input
Input: 0x88303dbd000000000000000000000000000000000000000000000000000000000000031c00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000010974d

Command: cast tx 0x3f6da406747a55797a7f84173cbb243f4fd929d57326fdcfcf8d7ca55b75fe99 to
Contract address: 0x5aF6D33DE2ccEC94efb1bDF8f92Bd58085432d2c

 ```
# Task 3 - Transaction Analysis

**Using the data that you got from the previous question, find the function name and parameters types that was called.**

```bash
Command: cast 4byte 0x88303dbd
function: buyTickets(uint256,uint32[])
```

**Decode the input data.**

```bash
Command: cast 4byte-decode 0x88303dbd000000000000000000000000000000000000000000000000000000000000031c00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000010974d

"buyTickets(uint256,uint32[])"
796
[1087309 [1.087e6]]
```

# Task 4 - Smart Contract Storage Analysis

**Get the previous task's smart contract's bytecodes.**

```bash
Command: cast code 0x5aF6D33DE2ccEC94efb1bDF8f92Bd58085432d2c
```

**Get the contract storage slots 0, 1, and 2.**

```bash
Command: cast storage 0x5aF6D33DE2ccEC94efb1bDF8f92Bd58085432d2c 0
0x0000000000000000000000000000000000000000000000000000000000000001
Command: cast storage 0x5aF6D33DE2ccEC94efb1bDF8f92Bd58085432d2c 1
0x00000000000000000000000021835332cbdf1b3530fae9f6cd66feb9477dfc02
Command: cast storage 0x5aF6D33DE2ccEC94efb1bDF8f92Bd58085432d2c 2
0x00000000000000000000000021835332cbdf1b3530fae9f6cd66feb9477dfc02
```

# Sensitive On Chain Data: Exercise 1 - Mastering CAST

```bash
uint256 private _status from ReentrancyGuard;
address private _owner from Ownable;
address public injectorAddress from contract ;
```