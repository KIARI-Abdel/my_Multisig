// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './MultiSigTransactions.sol';

/**
 * @title MultiSigMaster Contract
 * @dev Extends MultiSigTransaction, providing additional functionality for a 'master' role.
 *      This contract allows for the master to perform certain administrative tasks, such as
 *      withdrawing funds and changing the master address. Inherits initializable pattern for
 *      upgradeable contracts.
 * @notice This contract should be used in scenarios where multi-signature functionality is
 *         required along with a distinct master role capable of performing specific administrative
 *         tasks. The contract ensures that only the designated master can call these sensitive functions.
 */
contract MultiSigMaster is MultiSigTransaction {
    /*
     *  Events
     */

    /**
    * @dev Emitted when funds are withdrawn from the contract.
    * @param receiver The address receiving the withdrawn funds.
    * @param amount The amount of Ether (in wei) withdrawn.
    */
    event Withdraw(address indexed receiver, uint256 amount);

    /**
    * @dev Emitted when the master of the contract is changed.
    * @param master The new master's address.
    */
    event MasterChanged(address indexed master);

    /*
     *  Storage
     */
    address private Master;


    /**
    * @dev Modifier that restricts the execution of the function to only the current master of the contract.
    * It reverts the transaction if the condition is not met.
    * @param owner The address to be checked against the current master's address.
    */
    modifier onlyMaster(address owner) {
        require(owner == Master, "This address doesn't have Master privileges");
        _;
    }

    /**
    * @dev Initializes the contract setting the initial and initializes transaction with owners, and quorum.
    * @param master The address that will be set as the initial master.
    * @param _owners Array of addresses that will be set as the owners.
    * @param _quorum The required quorum for transaction approval.
    */
    constructor(
        address master,
        address[] memory _owners,
        uint256 _quorum
        ) public MultiSigTransaction(_owners, _quorum) {
        Master = master;
    }

    /**
    * @dev Returns the contract's current Ether balance, but only callable by the master.
    * @return The balance of Ether held by the contract.
    */
    function getBalance() public onlyMaster(msg.sender) view returns (uint) {
        return address(this).balance;
    }

    /**
    * @dev Withdraws the specified amount of Ether from the contract to a given address. 
    * Only callable by the master.
    * @param to The address to which the funds will be withdrawn.
    * @param amount The amount to be withdrawn.
    * @return sent A boolean indicating whether the withdrawal was successful.
    */
    function withdraw(address to, uint256 amount) external onlyMaster(msg.sender) returns (bool) {
        (bool sent, bytes memory data) = to.call{ value: amount }("");
        require(sent, "Withdraw transfer failed");
        emit Withdraw(to, amount);
        return sent;
    }

    /**
    * @dev Changes the master of the contract. Only the current master can call this function.
    * @param newMaster The address of the new master.
    */
    function changeMaster(address newMaster) external onlyMaster(msg.sender) {
        Master = newMaster;
        emit MasterChanged(newMaster);
    }

    /**
    * @dev Retrieves the address of the current master of the contract. 
    * This function can only be called by the master.
    * @return res The address of the current master.
    */
    function getMaster() external view onlyMaster(msg.sender) returns (address res) {
        res = Master;
    }
}