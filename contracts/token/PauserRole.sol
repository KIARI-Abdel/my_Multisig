// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './Roles.sol';

/**
 * @title PauserRole
 * @dev Abstract contract for managing a pauser role, inheriting from the Roles library. 
 *      Provides the functionality to add and remove pausers.
 * @notice This contract is used to assign and manage accounts that have the capability 
 *         to pause and unpause contract functionalities (when combined with Pausable).
 */
abstract contract PauserRole {
    using Roles for Roles.Role;


    /**
     *  Events
     */

    /**
    * @dev Emitted when a new pauser is added.
    * @param account The address that is granted the pauser role.
    */
    event PauserAdded(address indexed account);

    /**
    * @dev Emitted when a pauser is removed.
    * @param account The address that is removed from the pauser role.
    */
    event PauserRemoved(address indexed account);

    /**
     *  Sotrage
     */
    Roles.Role private _pausers;

    /**
    * @dev Initializes the contract by assigning the deployer as the initial pauser.
    */
    constructor () internal {
        _addPauser(msg.sender);
    }

    /**
    * @dev Modifier to make a function callable only by accounts with the pauser role.
    */
    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    /**
    * @dev Checks if an account is a pauser.
    * @param account The address to check.
    * @return A boolean indicating whether the account has the pauser role.
    */
    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    /**
    * @dev Adds a new account to the pauser role. Can only be called by an existing pauser.
    * @param account The address to be added to the pauser role.
    */
    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    /**
    * @dev Allows an account to renounce its role as a pauser.
    */
    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    /**
    * @dev Internal function to add an account to the pauser role.
    * @param account The address to be added to the pauser role.
    */
    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    /**
    * @dev Internal function to remove an account from the pauser role.
    * @param account The address to be removed from the pauser role.
    */
    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}