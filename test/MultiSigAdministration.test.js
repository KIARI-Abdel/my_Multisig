const { ethers } = require("hardhat");
const { solidity } = require("ethereum-waffle");
const { assert, expect } = require("chai");
const chai = require("chai");
chai.use(solidity);
const {
  deployMultiSig,
} = require('./helpers/deployContracts.js');


describe("Hardhat tests of the MultiSig Administration", function () {
  let multisig, multisigAddress, master, owners, owner1, owner2, newOwner, nonOwner, receiver, myToken, myTokenAddress, hashId, id, receipt, tx;
  const quorum = 2;
  const value = 1;

  before(async function () {
    [master, owner1, owner2, newOwner, nonOwner, receiver] = await ethers.getSigners();
    owners = [owner1.address, owner2.address];
  });

  describe("Administration Functions tests: ", async function () {

    before(async function () {
      multisig = await deployMultiSig(master.address, owners, quorum);
      multisigAddress = await multisig.getAddress();
    });

    describe("Test correct contract initialization through get functions testing: ", async function () {

      it("Get Quorum and compare it : ", async function () {
        let actualQuorum = await multisig.getQuorum();
        assert.equal(actualQuorum, quorum);
      });

      it("Get Owners and compare them : ", async function () {
        let actualOwners = await multisig.getOwners();
        await expect(actualOwners).to.eql(owners);
      });

      it("Verify Owner : ", async function () {
        let verif1 = await multisig.verifyOwner(owners[0]);
        let verif2 = await multisig.verifyOwner(owners[1]);
        assert.equal(verif1, verif2);
        assert.equal(verif1, true);
      });

      it("Get Owner Count and compare it : ", async function () {
        let actualOwnerCount = await multisig.getOwnerCount();
        assert.equal(actualOwnerCount, owners.length);
      });
    });


    describe("Test Administration functions : ", async function () {

      it("Test Remove Owner, should trigger quorum change (since owners = 2 & quorum = 2): ", async function () {
        let transactionType = 1;
        res = await multisig.connect(owner1).submitTransaction(owner2.address, 0, transactionType);
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

        res = await multisig.connect(owner1).executeTransaction(id);
        tx = await res.wait();

        let newQuorum = tx.logs[0].args[0];
        assert.equal(tx.logs[0].fragment.name, "QuorumChanged");
        assert.equal(Number(newQuorum), quorum - 1);

        assert.equal(tx.logs[1].fragment.name, "OwnerRemoval");
        assert.equal(tx.logs[1].args[0], owner2.address);

        res = await multisig.getOwners();
        assert.equal(res[0], owner1.address);
        assert.equal(res.length, owners.length - 1);

        let verif = await multisig.verifyOwner(owner2.address);
        assert.equal(verif, false);

        let count = await multisig.getOwnerCount();
        assert.equal(Number(count), owners.length - 1);
      });

      it("Test Add Owner : ", async function () {
        let actualOwners = await multisig.getOwners();
        let transactionType = 0;
        res = await multisig.connect(owner1).submitTransaction(owner2.address, 0, transactionType);
        tx = await res.wait();
        assert.equal(tx.logs[0].fragment.name, "Submission");
        hashId = tx.logs[0].args[0];
        id = tx.logs[0].args[1];

        res = await multisig.connect(owner1).confirmTransaction(id);
        tx = await res.wait();
        assert.equal(tx.logs[0].fragment.name, "Confirmation");

        res = await multisig.connect(owner1).executeTransaction(id);
        tx = await res.wait();
        assert.equal(tx.logs[0].fragment.name, "OwnerAddition");
        assert.equal(tx.logs[0].args[0], owner2.address);
      });

      it("Test Change Quorum : ", async function () {
        let transactionType = 2;
        res = await multisig.connect(owner1).submitTransaction(owner1.address, 1, transactionType);
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

        res = await multisig.connect(owner1).executeTransaction(id);
        tx = await res.wait();
        let newQuorum = tx.logs[0].args[0];
        assert.equal(tx.logs[0].fragment.name, "QuorumChanged");
        assert.equal(Number(newQuorum), 1);
      });
    });
  });
});
