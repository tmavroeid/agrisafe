import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-deploy';
import '@typechain/hardhat';
import { HardhatUserConfig } from 'hardhat/config';
import '@nomiclabs/hardhat-solhint';
import '@nomicfoundation/hardhat-chai-matchers';
import '@nomicfoundation/hardhat-network-helpers';

export const compilerConfig = (version: string) => ({
  version,
  settings: {
    evmVersion: 'paris',
    optimizer: {
      enabled: true,
      runs: 5000
    },
    outputSelection: {
      '*': {
        SavingsContract: ['storageLayout']
      }
    }
  }
});

const hardhatConfig: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: false,
      initialBaseFeePerGas: 0
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: 'https://sepolia-rollup.arbitrum.io/rpc',
      accounts: []
    },
    arbitrum: {
      chainId: 42161,
      url: 'https://arb1.arbitrum.io/rpc',
      accounts: []
    }
  },
  solidity: {
    compilers: [{ ...compilerConfig('0.8.24')}]
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache_hardhat',
    artifacts: './artifacts'
  },
  typechain: {
    outDir: 'types/generated',
    target: 'ethers-v5'
  },
  mocha: {
    timeout: 120e3, // 120s
    retries: 1
  }
};

export default hardhatConfig;
