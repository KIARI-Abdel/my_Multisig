const { ethers } = require("hardhat");
const { upgrades } = require("hardhat");

async function main() {
    //Multisig Factory deployment
    const mltsgFactory = await ethers.getContractFactory("MultiSigFactory");

    const mltsgFactoryProxy = await upgrades.deployProxy(mltsgFactory);
    const mltsgFactoryAddress = await mltsgFactoryProxy.getAddress();
    console.log("Multi-Sig Factory proxy is deployed to:", mltsgFactoryAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });