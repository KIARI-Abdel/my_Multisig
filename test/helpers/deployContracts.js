const { ethers } = require("hardhat");

async function deployMultiSig(masterAddress, ownersAddress, quorum) {
    const MultiSig = await ethers.getContractFactory("MultiSigMaster");

    const mltsgContract = await ethers.deployContract(
        "MultiSigMaster",
        [masterAddress, ownersAddress, quorum]
    );
    const mlstgAddress = await mltsgContract.getAddress()
    console.log("Multi-Sig Master is deployed to:", mlstgAddress);

    return mltsgContract;
}

async function deployFactory() {
    const mltsgFactoryContract = await ethers.deployContract("MultiSigFactory");
    const mltsgFactoryAddress = await mltsgFactoryContract.getAddress();
    console.log("Multi-Sig Factory is deployed to:", mltsgFactoryAddress);

    return mltsgFactoryContract;
}

async function deployMyToken(name, symbol, decimal, totalSupply) {
    const signers = await ethers.getSigners();
    const myToken = await ethers.deployContract("MyToken", [name, symbol, decimal, totalSupply]);
    const myTokenAddress = await myToken.getAddress();
    console.log("MyToken is deployed to:", myTokenAddress);

    return myToken;
}

module.exports = {
    deployMultiSig,
    deployFactory,
    deployMyToken,
};
