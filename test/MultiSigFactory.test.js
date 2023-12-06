const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const { assert, expect } = require("chai");
const chai = require("chai");
chai.use(solidity);
const {
    deployFactory,
} = require('./helpers/deployContracts.js');



describe("Hardhat tests of the MultiSig Factory", function () {
    let multisig, multisigAddress, master, owners, owner1, owner2, newOwner, nonOwner, receiver, myToken, myTokenAddress, hashId, id, receipt, tx;
    const quorum = 2;
    const value = 1;

    before(async function () {
        [master, owner1, owner2, newOwner, nonOwner, receiver] = await ethers.getSigners();
        owners = [owner1.address, owner2.address];
    });

    describe("Factory Functions tests: ", async function () {

        beforeEach(async function () {
            factory = await deployFactory(master.address, owners, quorum);
            factoryAddress = await factory.getAddress();
        });

        describe("Test correct contract initialization through get functions testing: ", async function () {

            it("Get Number Of MultiSigs : ", async function () {
                let count = await factory.getNumberOfMultiSigs();
                assert.equal(count, 0);
            });
        });

        describe("Teste creation of new instances of multisig : ", async function () {

            it("CreateMultiSig and verify through all get functions: ", async function () {
                let res = await factory.createMultiSigAdministration(owners, quorum);
                tx = await res.wait();
                let event1 = tx.logs[1].fragment.name;
                let event2 = tx.logs[2].fragment.name;
                let instance1 = tx.logs[2].args[0];
                assert.equal(event1, "ContractInstantiation");
                assert.equal(event2, "MultiSigAdministrationCreation");

                let actualInstances = await factory.getInstancesOfMultisigs();
                assert.equal(instance1, actualInstances[0]);

                let actualCount = await factory.getNumberOfMultiSigs();
                assert.equal(actualCount, 1);
            });
        });

    });
});
