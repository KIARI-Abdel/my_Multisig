// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/console.sol";

import { MultiSigAdministration } from "../../contracts/MultiSigAdministration.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract MultiSigTest is Test {
    MultiSigAdministration internal mltsg;
    uint256 quorum = 2;
    address [] public owners = [0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8];

    event Deposit(uint256 amount);
    event OwnerRemoval(address indexed owner);
    event OwnerAddition(address indexed owner);
    event QuorumChanged(address indexed user, uint256 quorum);


    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        mltsg = new MultiSigAdministration();
        mltsg.initialize(owners, quorum);
    }

    function test_getQuorum() public {
        uint256 actualQuorum = mltsg.getQuorum();
        assertEq(actualQuorum, quorum);
    }

    function test_verifyOwner() public {
        bool res = mltsg.verifyOwner(owners[0]);
        assertEq(res, true);
        res = mltsg.verifyOwner(owners[1]);
        assertEq(res, true);
    }

    function test_getOwnerCount() public {
        uint256 res = mltsg.getOwnerCount();
        assertEq(res, 2);
    }
}
