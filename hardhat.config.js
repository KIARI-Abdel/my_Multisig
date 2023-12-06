require("dotenv").config();
require("hardhat-abi-exporter");
require("hardhat-deploy");
require("hardhat-watcher");
require("hardhat-contract-sizer");
require("hardhat-docgen");
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-solhint");

require("@nomiclabs/hardhat-etherscan");
require("solidity-coverage");
require('@openzeppelin/hardhat-upgrades');


require("./tasks/accounts");

//require("@nomiclabs/hardhat-ethers");
//require("@nomiclabs/hardhat-waffle");


const { removeConsoleLog } = require("hardhat-preprocessor");

const chainIds = {
  ganache: 1337,
  goerli: 5,
  hardhat: 31337,
};



const infuraApiKey = process.env.INFURA_API_KEY;
if (!infuraApiKey) {
  throw new Error("Please set your INFURA_API_KEY in a .env file");
}


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts", // build
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      initialDate: "1970-01-01T00:00:00Z",
    },
    localhost: {
      url: "http://127.0.0.1:8545/",
      gasLimit: 8000000,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 5,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      gasLimit: 8000000,
      gasPrice: 10,
    },

    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
      gasMultiplier: 1.2,

    },

  },
  abiExporter: {
    path: "./abi",
    clear: true,
    flat: true,
    only: [],
    except: [],
    spacing: 2,
  },
  preprocess: {
    eachLine: removeConsoleLog(bre => bre.network.name !== "hardhat" && bre.network.name !== "localhost"),
  },
  gasReporter: {
    currency: "USD",
    enabled: !!process.env.REPORT_GAS,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    outputFile: "gas-report.txt",
  },
  watcher: {
    compilation: {
      tasks: ["compile"],
      files: ["./contracts"],
      verbose: true,
    },
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: false,
    disambiguatePaths: false,
  },
  docgen: {
    path: "./docs",
    clear: true,
    runOnCompile: false,
  },
  namedAccounts: {
    deployer: {
      default: 0, // take the first account as deployer
    },
  },
  mocha: {
    timeout: 60000,
  },
};
