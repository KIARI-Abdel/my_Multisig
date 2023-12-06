const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const { assert, expect } = require("chai");
const chai = require("chai");
chai.use(solidity);
const {
    deployMultiSig,
} = require('./helpers/deployContracts.js');

const {
    approveContract,
    depositOnContract,
} = require('./helpers/testHelpers.js');


describe("Hardhat tests of the MultiSig Master", function () {
    let multisig, multisigAddress, master, owners, owner1, owner2, newOwner, nonOwner, receiver, myToken, myTokenAddress, hashId, id, receipt, tx;
    const quorum = 2;
    const value = 1;

    before(async function () {
        [master, owner1, owner2, newOwner, nonOwner, receiver] = await ethers.getSigners();
        owners = [owner1.address, owner2.address];
    });


    describe("Master Functions tests: ", async function () {

        before(async function () {
            multisig = await deployMultiSig(master.address, owners, quorum);
            multisigAddress = await multisig.getAddress();

            await depositOnContract(multisig, master);
        });

        describe("Test correct contract initialization through get functions testing: ", async function () {

            it("Get Master and compare it : ", async function () {
                let actualMaster = await multisig.getMaster();
                assert.equal(actualMaster, master.address);
            });
        });

        describe("Test Administration functions : ", async function () {

            it("Change Master : ", async function () {
                let res = await multisig.changeMaster(owner1.address);
                tx = await res.wait();
                let newMaster = tx.logs[0].args[0];
                let event = tx.logs[0].fragment.name;
                assert.equal(event, "MasterChanged");
                assert.equal(newMaster, owner1.address);
            });

            it("Withdraw : ", async function () {
                let balance = await multisig.connect(owner1).getBalance();
                const amountToWithdraw = ethers.parseEther("10");
                assert.equal(balance, amountToWithdraw);

                let res = await multisig.connect(owner1).withdraw(owner2.address, amountToWithdraw);
                tx = await res.wait();
                let event = tx.logs[0].fragment.name;
                let destination = tx.logs[0].args[0];
                let amount = tx.logs[0].args[1];
                assert.equal(event, "Withdraw");
                assert.equal(destination, owner2.address);
                assert.equal(amount, amountToWithdraw);
            });
        });

    });
});
