const { ethers } = require("hardhat");

async function main() {
    // Factory deployment
    const deployedLibrary = await ethers.deployContract("Factory");
    const libraryAddress = await deployedLibrary.getAddress();
    console.log("Library is deployed to:", libraryAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
