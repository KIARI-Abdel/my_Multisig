// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Factory {
    event ContractInstantiation(address sender, address instantiation);

    mapping(address => bool) public isInstantiated;
    mapping(address => address[]) public instantiations;

    function getInstantiationCount(address creator) public view returns (uint256) {
        return instantiations[creator].length;
    }
    
    function register(address instantiation) internal {
        isInstantiated[instantiation] = true;
        instantiations[msg.sender].push(instantiation);
        emit ContractInstantiation(msg.sender, instantiation);
    }
}
