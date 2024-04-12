import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "hardhat-tracer";
import 'dotenv/config';

// Constants
const MAINNET_FORK_BLOCK_NUMBER = 15969633;

const MAINNET = process.env.ETH_RPC_URL;
if (!MAINNET) console.log('Warning: MAINNET not found in .env\n');

const config: HardhatUserConfig = {
	solidity: {
		compilers: [
			{
				version: '0.8.13',
			},
		],
	},
  paths: { 
    "sources": "./src",
    "artifacts": "./artifacts"
  },
};

let scriptName;

const lastArg = process.argv[process.argv.length - 1];
if (lastArg != undefined) {
	scriptName = lastArg;
} else {
	scriptName = '';
}
if (scriptName.includes('frontrunning') || scriptName.includes('optimizer-vaults-1')) {
	// Frontrunning exercises are with "hardhat node mode", mining is done via rpc call
	console.log(`Forking Mainnet Block Height ${MAINNET_FORK_BLOCK_NUMBER}, Manual Mining Mode`);
	config.networks = {
		hardhat: {
			forking: {
				url: MAINNET!,
				blockNumber: MAINNET_FORK_BLOCK_NUMBER,
			},
			mining: {
				auto: false,
				interval: 0,
			},
			gas: 'auto',
		},
	};
}

export default config;
