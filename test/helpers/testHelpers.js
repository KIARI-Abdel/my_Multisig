const { ethers } = require("hardhat");
const { assert } = require("chai");

async function approveContract(tokenAddress, multisigAddress, signer) {
    let contract = await ethers.getContractFactory("MyToken");
    let myToken = contract.attach(tokenAddress);

    let spenderAddress = multisigAddress;
    const amountToApprove = ethers.parseEther("100");

    const approveTx = await myToken.connect(signer).approve(spenderAddress, amountToApprove, { gasLimit: 100000 });
    receipt = await approveTx.wait();
}

async function depositOnContract(multisig, signer) {
    const amountToSend = ethers.parseEther("10");
    let approveTx = await multisig.deposit({ value: amountToSend });
    receipt = await approveTx.wait();

    let balance = await multisig.connect(signer).getBalance();
    assert.equal(balance, amountToSend);
}

module.exports = {
    approveContract,
    depositOnContract,
};
