## Smart Contracts Hacking Course Part 2

![image](https://user-images.githubusercontent.com/91771249/227430056-d7971b2d-d707-49df-a10e-93c4118c76a6.png)
_{Credit: Paradigm}_

**In this repo you will find 95% of the exercises for SCHC Part 2, written in Forge**

> Some exercises could not be written using Forge; therefore, we will opt-in for Hardhat with them. There are two reasons for this decision. First, Forge doesn't provide access to transactions, making it impossible to simulate front-running scenarios. Second, the `selfdestruct` opcode doesn't behave as expected in Forge. See the **Hardhat** section for more details on how to run these exercises.

---

## Requirements

1. [Install Foundry on your computer.](https://book.getfoundry.sh/getting-started/installation)
2. [Install Node](https://nodejs.org/en/download/package-manager), as we will need Hardhat for 4 of the exercises.


## Setup
1. Create a `.env` file in the root folder and replace the necessary api keys.
2. Run `forge build` to build project and clone dependencies.
3. Run `npm install`

Once you go through these points, you should be able to run any test in the repo.

#### Forge Dependencies
All necessary dependencies are already added as git submodules, as [required by the official docs](https://book.getfoundry.sh/projects/dependencies).
In case you want to get a different version of a dependency you can run:
`forge install OpenZeppelin/openzeppelin-contracts@v[release_version]`
The currently used one is v4.8.0.

To check a dependency version, open terminal, navigate to the submodule and type `git show` to see info about the latest commit (and tag if any).

Import statement example:
`import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";`

#### [Remappings](https://book.getfoundry.sh/config/vscode#1-remappings)

To make import statements concise and work with VSCode, paths are remapped in **remappings.txt**.

To support VSCode autocompletion and navigation, default directories were set in `.vscode/settings.json`.

## Testing with Forge

In **Forge** each test function is run in isolation (unlike **Hardhat**). This ensures tests are independent and don't affect each other.

For the purpose of the SCH exercises there is mostly one test function. Otherwise, the continuity required for some of the exercises would be hard to achieve without a lot of boilerplate code. Just follow the comments and you will be good.

#### Useful commands
`forge test` - runs all tests

Possible flags:
* `--fork_url [value]` - Forks the specified blockchain with URL. Used for running tests on real networks. Value can be either **rpc_endpoint**(as specified in **foundry.toml**) or a direct URL literal.
* `--fork-block-number [block_number]` - At which block number the fork should occur.
* `--match-contract [contract_name]` - Run tests only for the specified contract.
* `--match-test [test_name]` - Run tests that match with the given test name.

Example: `forge test --fork-url mainnet --fork-block-number 15969633 --match-contract DEX1`
Example 2: `forge test -vvv --match-contract UR2`

## Hardhat specific exercises

**Some important commands**

Run `npx hardhat compile` to compile files and create artifacts.

To enable traces add `--vvvv` after the test command, like this:
`npx hardhat test --vvvv path/to/tests.ts`
> This capability is enabled via the `hardhat-tracer` package.

To run tests for a particular exercise see comments in the file.
Example: `npx hardhat test test/frontrunning-1/tests.ts`

List of exercises using **Hardhat**
 - call-attacks-4
 - frontrunning-1
 - frontrunning-2
 - frontrunning-3
 - optimizer-vaults-1
