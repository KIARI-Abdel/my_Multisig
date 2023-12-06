// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './ERC20.sol';
import './Pausable.sol';

/**
 * @title Pausable ERC20 Token
 * @dev Extension of ERC20 that adds pausability to all token transfers, allowances, 
 *      and approvals. Inherits functionalities from ERC20 and Pausable contracts.
 * @notice This contract is used to create an ERC20 token with an additional feature 
 *         that allows token transfers to be paused and resumed by an authorized account.
 */
contract ERC20Pausable is ERC20, Pausable {
    
    /**
    * @dev Transfers tokens to a specified address. Transaction is allowed only when not paused.
    * @param to The address to transfer tokens to.
    * @param value The amount of tokens to be transferred.
    * @return A boolean value indicating whether the operation succeeded.
    */
    function transfer(address to, uint256 value) public whenNotPaused override returns (bool) {
        return super.transfer(to, value);
    }

    /**
    * @dev Transfers tokens to a specified address. Transaction is allowed only when not paused.
    * @param to The address to transfer tokens to.
    * @param value The amount of tokens to be transferred.
    * @return A boolean value indicating whether the operation succeeded.
    */
    function transferFrom(address from, address to, uint256 value) public whenNotPaused override returns (bool) {
        return super.transferFrom(from, to, value);
    }

    /**
    * @dev Approves the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *      Transaction is allowed only when not paused.
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    * @return A boolean value indicating whether the operation succeeded.
    */
    function approve(address spender, uint256 value) public whenNotPaused override returns (bool) {
        return super.approve(spender, value);
    }

    /**
    * @dev Increases the amount of tokens that an owner allowed to a spender. 
    *      Transaction is allowed only when not paused.
    * @param spender The address which will spend the funds.
    * @param addedValue The amount of tokens to increase the allowance by.
    * @return success A boolean value indicating whether the operation succeeded.
    */
    function increaseAllowance(address spender, uint addedValue) public whenNotPaused override returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    /**
    * @dev Decreases the amount of tokens that an owner allowed to a spender.
    *      Transaction is allowed only when not paused.
    * @param spender The address which will spend the funds.
    * @param subtractedValue The amount of tokens to decrease the allowance by.
    * @return success A boolean value indicating whether the operation succeeded.
    */
    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused override returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}