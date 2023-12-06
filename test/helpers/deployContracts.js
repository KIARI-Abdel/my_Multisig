const { ethers } = require("hardhat");

async function deployMultiSig(masterAddress, ownersAddress, quorum) {
    const MultiSig = await ethers.getContractFactory("MultiSigMaster");

    const mltsgProxy = await upgrades.deployProxy(
        MultiSig,
        [masterAddress, ownersAddress, quorum],
        {
            initializer: "initialize(address, address[],uint256)",
        },
        {
            gas: 1000000,
            gasPrice: 100,
        }
    );
    const mlstgAddress = await mltsgProxy.getAddress()
    console.log("Multi-Sig Master proxy is deployed to:", mlstgAddress);

    return mltsgProxy;
}

async function deployFactory() {
    const mltsgFactory = await ethers.getContractFactory("MultiSigFactory");

    const mltsgFactoryProxy = await upgrades.deployProxy(mltsgFactory);
    const mltsgFactoryAddress = await mltsgFactoryProxy.getAddress();
    console.log("Multi-Sig Factory proxy is deployed to:", mltsgFactoryAddress);

    return mltsgFactoryProxy;
}

module.exports = {
    deployMultiSig,
    deployFactory,
};
