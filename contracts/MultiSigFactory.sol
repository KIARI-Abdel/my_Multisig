// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Factory.sol";
import "./MultiSigAdministration.sol";

/**
 * @title Multi-Signature Factory Contract
 * @dev Contract to create new instances of MultiSigTransaction and MultiSigMaster contracts.
 * @notice This factory contract serves as a centralized point for creating and keeping track
 *         of various multi-signature wallets or contracts.
 */
contract MultiSigFactory is Factory {
    /*
     *  Events
     */
     
    /**
    * @dev Emitted when a new MultiSigMaster contract is created.
    * @param multiSig The address of the newly created MultiSigMaster contract.
    */
    event MultiSigAdministrationCreation(address indexed multiSig);

    /*
     *  Storage
     */
    address[] public multiSigs;
 
    /**
    * @dev Creates a new MultiSigMaster contract with specified owners, quorum, and a master address.
    * @param owners Array of addresses that will be the owners in the created MultiSigMaster.
    * @param quorum The number of required confirmations for a transaction.
    * @return wallet The address of the newly created MultiSigMaster contract.
    */
    function createMultiSigAdministration(address[] memory owners, uint256 quorum) public returns (address wallet) {
        MultiSigAdministration multiSig = new MultiSigAdministration(owners, quorum);
        wallet = address(multiSig);
        multiSigs.push(wallet);
        register(wallet);
        emit MultiSigAdministrationCreation(wallet);
    }

    /**
    * @dev Returns the number of multi-signature contracts created by this factory.
    * @return The total number of multi-signature contracts created.
    */
    function getNumberOfMultiSigs() external view returns (uint256) {
        return multiSigs.length;
    }

    /**
    * @dev Returns the addresses of all multi-signature contracts created by this factory.
    * @return A list of addresses of the multi-signature contracts.
    */
    function getInstancesOfMultisigs() external view returns (address[] memory) {
        return multiSigs;
    }
}
