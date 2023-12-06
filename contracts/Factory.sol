// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Contract Factory
 * @dev Factory pattern implementation for creating and keeping track of contract instances.
 * @notice This contract serves as a registry for contract instances, providing functionalities to register and query instances.
 */
contract Factory {
    /*
     *  Events
     */
    
    /**
    * @dev Emitted when a new contract instance is registered in the factory.
    * @param sender The address that created and registered the contract instance.
    * @param instantiation The address of the newly created contract instance.
    */
    event ContractInstantiation(address sender, address instantiation);

    /*
     *  Storage
     */
    mapping(address => bool) public isInstantiated;
    mapping(address => address[]) public instantiations;

    /**
    * @dev Retrieves the count of contract instances created by a specific address.
    * @param creator The address of the creator whose instantiations are being counted.
    * @return The number of contract instances created by the specified creator.
    */
    function getInstantiationCount(address creator) public view returns (uint256) {
        return instantiations[creator].length;
    }
    
    /**
    * @dev Registers a new contract instance in the factory. 
    *      This function is internal and can only be called within the contract or its children.
    * @param instantiation The address of the new contract instance to be registered.
    */
    function register(address instantiation) internal {
        isInstantiated[instantiation] = true;
        instantiations[msg.sender].push(instantiation);
        emit ContractInstantiation(msg.sender, instantiation);
    }
}
