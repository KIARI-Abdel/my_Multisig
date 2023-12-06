const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const { assert, expect } = require("chai");
const chai = require("chai");
chai.use(solidity);
const {
    deployMultiSig,
    deployMyToken,
} = require('./helpers/deployContracts.js');

const {
    approveContract,
    depositOnContract,
} = require('./helpers/testHelpers.js');


describe("Hardhat tests of the MultiSig Transaction", function () {
    let multisig, multisigAddress, master, owners, owner1, owner2, newOwner, nonOwner, receiver, myToken, myTokenAddress, hashId, id, receipt, tx;
    const quorum = 2;
    const value = 1;

    before(async function () {
        [owner1, owner2, newOwner, nonOwner, receiver, master] = await ethers.getSigners();
        owners = [owner1.address, owner2.address];
    });

    describe("Transaction Functions tests: ", async function () {

        before(async function () {
            multisig = await deployMultiSig(master.address, owners, quorum);
            multisigAddress = await multisig.getAddress();

            myToken = await deployMyToken("MyToken", "MTK", 18, 1000000);
            myTokenAddress = await myToken.getAddress();
            await approveContract(myTokenAddress, multisigAddress, owner1);

            await depositOnContract(multisig, master);
        });

        describe("Test Transaction functions : ", async function () {

            it("Submit Transaction : ", async function () {
                let transactionType = 3;
                const amountToSend = ethers.parseEther("5");
                res = await multisig.connect(owner1).submitTransaction(receiver.address, amountToSend, transactionType);
                tx = await res.wait();
                assert.equal(tx.logs[0].fragment.name, "Submission");
                hashId = tx.logs[0].args[0];
                id = tx.logs[0].args[1];
            });

            it("revoke transaction : ", async function () {
                res = await multisig.connect(owner1).revokeTransaction(id);
                tx = await res.wait();
                assert.equal(tx.logs[0].fragment.name, "Revocation");
                res = await multisig.connect(owner2).revokeTransaction(id);
                tx = await res.wait();
                assert.equal(tx.logs[0].fragment.name, "Revocation");
            });

            it("Confirm Transaction : ", async function () {
                res = await multisig.connect(owner1).confirmTransaction(id);
                tx = await res.wait();
                assert.equal(tx.logs[0].fragment.name, "Confirmation");
                res = await multisig.connect(owner2).confirmTransaction(id);
                tx = await res.wait();
                assert.equal(tx.logs[0].fragment.name, "Confirmation");
            });

            it("Execute Transaction = sending native ", async function () {
                let provider = ethers.getDefaultProvider();
                const amountToSend = ethers.parseEther("5");
                let userBalanceBeforeWithdraw = await ethers.provider.getBalance(receiver.address);
                let contractBalanceBeforeWithdraw = await multisig.connect(master).getBalance();

                res = await multisig.connect(owner1).executeTransaction(id);
                tx = await res.wait();

                let amount = tx.logs[0].args[0];
                let event = tx.logs[0].fragment.name;
                assert.equal(event, "ExecutionNative");
                assert.equal(amount, amountToSend);

                let userBlanceAfterWithdraw = await ethers.provider.getBalance(receiver.address);
                let contractBalanceAfterWithdraw = await multisig.connect(master).getBalance();

                assert.equal(userBalanceBeforeWithdraw + amountToSend, userBlanceAfterWithdraw);
                assert.equal(contractBalanceAfterWithdraw + amountToSend, contractBalanceBeforeWithdraw);
            });
            /*
                        it("Execute Transaction = sending ERC20 ", async function () {
                            let transactionType = 4;
                            const amountToSend = ethers.parseEther("3");
                            res = await multisig.connect(owner1).submitTransaction(receiver.address, amountToSend, transactionType);
                            tx = await res.wait();
                            assert.equal(tx.logs[0].fragment.name, "Submission");
                            hashId = tx.logs[0].args[0];
                            id = tx.logs[0].args[1];
            
            
                            res = await multisig.connect(owner1).confirmTransaction(id);
                            tx = await res.wait();
                            assert.equal(tx.logs[0].fragment.name, "Confirmation");
                            res = await multisig.connect(owner2).confirmTransaction(id);
                            tx = await res.wait();
                            assert.equal(tx.logs[0].fragment.name, "Confirmation");
            
            
                            let provider = ethers.getDefaultProvider();
                            let userBalanceBeforeWithdraw = await myToken.balanceOf(receiver.address);
            
                            res = await multisig.connect(owner1).executeTransaction(id);
                            tx = await res.wait();
            
                            let amount = tx.logs[0].args[0];
                            let event = tx.logs[0].fragment.name;
                            assert.equal(event, "ExecutionERC20");
                            assert.equal(amount, amountToSend);
            
                            let userBalanceAfterWithdraw = await myToken.balanceOf(receiver.address);
                            assert.equal(userBalanceBeforeWithdraw + amountToSend, userBalanceAfterWithdraw);
                        });*/
        });
    });
});
