const { ethers } = require("hardhat");

async function deployFactory() {
    const mltsgFactory = await ethers.getContractFactory("MultiSigFactory");

    const mltsgFactoryProxy = await upgrades.deployProxy(mltsgFactory);
    const mltsgFactoryAddress = await mltsgFactoryProxy.getAddress();
    console.log("Multi-Sig Factory proxy is deployed to:", mltsgFactoryAddress);

    return mltsgFactoryProxy;
}


module.exports = {
    deployFactory,
};
