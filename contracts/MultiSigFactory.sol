// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Factory.sol";
import "./MultiSigAdministration.sol";

contract MultiSigFactory is Factory {
    event MultiSigAdministrationCreation(address indexed multiSig);

    address[] public multiSigs;
 
    function createMultiSigAdministration(address[] memory owners, uint256 quorum) public returns (address wallet) {
        MultiSigAdministration multiSig = new MultiSigAdministration(owners, quorum);
        wallet = address(multiSig);
        multiSigs.push(wallet);
        register(wallet);
        emit MultiSigAdministrationCreation(wallet);
    }

    function getNumberOfMultiSigs() external view returns (uint256) {
        return multiSigs.length;
    }

    function getInstancesOfMultisigs() external view returns (address[] memory) {
        return multiSigs;
    }
}
