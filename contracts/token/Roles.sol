// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title Roles
 * @dev Library for managing and manipulating roles. Primarily used for role-based access control.
 * @notice This library provides a flexible and efficient way to manage role-based permissions
 *         across various contracts that require fine-grained access control.
 */
library Roles {

    /**
     *  Storage
     */

    /**
    * @dev Defines a Role data structure, encapsulating a mapping of addresses to boolean values.
    *      Used to represent the set of accounts that have a particular role.
    */
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}