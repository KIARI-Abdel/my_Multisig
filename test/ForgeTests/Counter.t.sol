// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { BCERTLockContract } from "../contracts/rewardPool.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract rewardPoolTest is Test {
    BCERTLockContract internal rp;
    uint256 quorum = 2;
    address [] public voters = [0xE0D0D580E9A473EB3392B315D27e33462364e300, 0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a];

    event Deposit(uint256 amount);
    event AssignedBCERT(address indexed recipient, uint256 amount);
    event ModifiedAssignedBCERT(address indexed recipient, uint256 newAmount);
    event ReleaseBCERT(address indexed recipient, uint256 amount);
    event RemovedVoter(address indexed owner);
    event AddedVoter(address indexed owner);
    event ChangedQuorum(uint256 quorum);
    event ChangedOwner(address indexed owner);


    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        rp = new BCERTLockContract();
        rp.initialize(quorum, voters);
    }

    function _send(uint256 amount) private {
        (bool ok,) = address(rp).call{value: amount}("");
        require(ok, "Sending funds failed");
    }

    function test_Deposit() public {
        deal(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 100);
        assertEq(address(0xE0D0D580E9A473EB3392B315D27e33462364e300).balance, 100);

        vm.expectEmit(false, false, false, true);
        emit Deposit(50); 
        vm.prank(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        _send(50);
        assertEq(address(rp).balance, 50);
        assertEq(address(0xE0D0D580E9A473EB3392B315D27e33462364e300).balance, 50);
    }


    function test_AssignAndLock() public {
        uint256 id;
        uint256 bal;
        BCERTLockContract.LockedBCERT memory res;
        hoax(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 100);
        _send(50);
        vm.expectEmit(true, false, false, true);
        emit AssignedBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 50);
        id = rp.assignAndLockBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 50);
        vm.prank(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        res = rp.getLockedBCERTs(id);
        assertEq(res.amount, 50);
        assertEq(res.recipient, address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a));
        bal = rp.getLockedBCERTBalance(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a));
        assertEq(bal, 50);
    }
    function testFail_AssignAndLockWithInvalidOwner() public {
        hoax(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 100);
        _send(50);
        vm.expectEmit(true, false, false, true);
        emit AssignedBCERT(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 50);
        vm.prank(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        rp.assignAndLockBCERT(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 50);
    }

    function test_OnlyOwnerModifier() public {
        vm.expectRevert(bytes("RP01"));
        vm.prank(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        rp.assignAndLockBCERT(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 50);
    }

    function test_AssignAndLockWithInvalidBalance() public {
        vm.expectRevert(bytes("RP04"));
        rp.assignAndLockBCERT(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 50);
    }

    function test_ModifyAssignedBCERT() public {
        uint256 id;
        uint256 bal;
        BCERTLockContract.LockedBCERT memory res;
        hoax(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 100);
        _send(100);
        id = rp.assignAndLockBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 50);
        vm.expectEmit(true, false, false, true);
        emit ModifiedAssignedBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 25);
        rp.modifyAssignedBCERT(id, address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 25);
        res = rp.getLockedBCERTs(id);
        assertEq(res.amount, 25);
        assertEq(res.recipient, address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a));
        bal = rp.getContractLockedBCERTBalance();
        assertEq(bal, 75);
    }

    function test_VoteAndRelease() public {
        uint256 id;
        uint256 bal = address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a).balance;
        hoax(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 100);
        _send(100);
        assertEq(address(0xE0D0D580E9A473EB3392B315D27e33462364e300).balance, 0);
        id = rp.assignAndLockBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 50);
        rp.addVoter(address(this));
        rp.voteForRelease(id);
        vm.prank(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a));
        rp.voteForRelease(id);
        assertEq(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a).balance, bal);
        vm.expectEmit(true, false, false, true);
        emit ReleaseBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 50);
        vm.prank(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        rp.releaseBCERT(id, 50);
        assertEq(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a).balance, bal + 50);
    }

    function test_onlyVoterModifier() public {
        vm.expectRevert(bytes("RP09"));
        vm.prank(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        rp.voteForChangeOwner();
        vm.expectEmit(true, false, false, false);
        emit AddedVoter(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        rp.addVoter(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        vm.prank(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        rp.voteForChangeOwner();
        vm.expectEmit(true, false, false, false);
        emit RemovedVoter(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        rp.removeVoter(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        vm.expectRevert(bytes("RP09"));
        vm.prank(address(0x4258B73A0A3F842D3c3Cdda2b6FEF12962A257D7));
        rp.voteForChangeOwner();
    }

    function test_ChangeOwner() public {
        vm.prank(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        rp.voteForChangeOwner();
        vm.prank(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a));
        rp.voteForChangeOwner();
        vm.expectEmit(true, false, false, false);
        emit ChangedOwner(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        rp.changeOwner(address(0xE0D0D580E9A473EB3392B315D27e33462364e300));
        vm.prank(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a));
        rp.voteForChangeOwner();
    }

    function test_ChangeQuorum() public {
        rp.addVoter(address(this));
        rp.changeQuorum(3);
    }
/*
    function test_ReleaseBCERT() public {
        uint256 id;
        uint256 bal;
        BCERTLockContract.LockedBCERT memory res;
        hoax(address(0xE0D0D580E9A473EB3392B315D27e33462364e300), 100);
        _send(100);
        assertEq(address(0xE0D0D580E9A473EB3392B315D27e33462364e300).balance, 0);
        id = rp.assignAndLockBCERT(address(0xcbD8fA191928a1411e36D5Db7b8826C6A5B3EB2a), 50);

    }
    */
}
