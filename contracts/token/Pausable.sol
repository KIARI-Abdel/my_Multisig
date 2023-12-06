// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './PauserRole.sol';

/**
 * @title Pausable
 * @dev Abstract contract providing an emergency stop mechanism, or "pause" feature. 
 *      Inherits from PauserRole to use role-based permissioning.
 * @notice Allows derived contracts to implement pausable functionality, enabling authorized 
 *         accounts to pause and unpause contract operations in case of an emergency or other 
 *         significant events.
 */
abstract contract Pausable is PauserRole {

    /**
     *  Events
     */

    /**
    * @dev Emitted when the contract is paused.
    * @param account The address of the account that triggered the pause.
    */
    event Paused(address account);

    /**
    * @dev Emitted when the contract is unpaused.
    * @param account The address of the account that triggered the unpausing.
    */
    event Unpaused(address account);


    /**
     *  Storage
     */
    bool private _paused;


    /**
    * @dev Initializes the contract in an unpaused state.
    */
    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}