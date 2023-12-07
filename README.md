# MultiSig Wallet Project

## Overview

This MultiSig Wallet project is a demonstration of Solidity and smart contract development skills. It's specifically designed for portfolio purposes and isn't intended for real-world deployment or use.

## Intentional Incoherences
There are a few intentional incoherences and unusual design choices in the smart contracts. These are deliberately included to showcase my ability to implement complex and non-standard features in Solidity, as well as to demonstrate a deep understanding of smart contract development. **Please note**, these incoherences are for demonstration purposes and not intended for real-world application.

## Project Description

The MultiSig Wallet is a smart contract system on the Ethereum blockchain, requiring multiple confirmations from a defined group of owners for transactions to be executed.
This demonstration includes handling Ether and ERC20 token transactions, adding or removing owners, and changing the required number of confirmations for transactions.

## Key Components
- MultiSigAdministration: Manages administrative tasks like adding or removing owners and changing the quorum.
- MultiSigTransaction: Handles the creation, confirmation, and execution of transactions.
- MultiSigMaster: Main contract that interacts with the Administration and Transaction contracts.
- MultiSigUtils: A library of utility functions supporting the main contracts.
- Factory: A generic contract factory framework.
- MultiSigFactory: Specialized factory for creating instances of the MultiSig Wallet.

## Features
- **Modular Design**: The contracts are separated into distinct modules for clear functionality separation.
- **Upgradability**: Implementing OpenZeppelin's upgradeable contracts for future improvements.
- **Multi-Signature Functionality**: Multiple owners with a defined quorum for transaction execution.
- **Manage Ownership**: Dynamic addition or removal of wallet owners.
- **Custom Factory Implementation**: For creating instances of the MultiSig wallet.
- **Support for Native and ERC20 Tokens**: Manage both Native and ERC20 token transactions.


## Installation and Setup

- Clone the Repository
```
git clone [repository URL]
```
- Install Dependencies
```
npm install
```
- Compile Contracts
```
npx hardhat compile
```
- Configure environment
create .env file in the root folder of the project.
Add needed variables:
```
- INFURA_API_KEY={Your Infura Key} 
```
```
- PRIVATE_KEY={The private Key of the account you want to use for deployment and testing} 
```
You can add up to 3 private keys without having to modify the hardhat config file, name them PRIVATE_KEY, PRIVATE_KEY_1, PRIVATE_KEY_2


## Tests

- Using Hardhat : 
```
npx hardhat test
```
Alternatively you can run a local node by opening a new terminal, navigating to the root folder in this project and run:
```
npx hardhat node
```
Then you can deploy to that local node by specifying the network:
```
npx hardhat test --network localhost
```
And get coverage using this command: 
```
npx hardhat coverage
```

- Using Forge:
```
forge build
```
then : 
```
forge test
```


## Deployment

Deploy contract
```
npx hardhat run script/deployFactory.js --network [Network Name Configured in the hardhat config file]
```
Then use the addressed of the contract log in the console to interact with the multiSigFactory contract to create new multiSig instances,
by calling the createMultiSigMaster function.
You will need to pass 3 parameters:
- owners : array of addresses of the owners of this instance of multiSig
- quorum : integer that represent the number of vote required to confirm any transaction on the multiSig
- master : the address of the master of the contract
This function will initialize a new instance of multiSig and return it address.

## Disclaimer

This project is a showcase of my development capabilities in the field of smart contracts and is not intended for real-world application. The code hasn't been audited and should be refrained from being deployed in any production environment.

## Contact

For inquiries or more information about this project or my other works, please reach out to abdel.kiari@gmail.com.