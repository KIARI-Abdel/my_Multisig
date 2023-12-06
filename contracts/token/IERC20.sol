// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 Standard Interface
 * @dev Interface of the ERC20 standard as defined in the EIP. 
 *      Defines the standard functions to manage transactions and track balances.
 * @notice This interface defines the standard functions for an ERC20 token, 
 *         including transfer, allowance, and balance tracking functionalities.
 */
interface IERC20 {

    /**
     *  Events
     */

    /**
    * @dev Emitted when tokens are transferred from one address to another.
    * @param from The address which is transferring tokens.
    * @param to The address which is receiving the tokens.
    * @param amount The amount of tokens being transferred.
    */
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /**
    * @dev Emitted when the allowance of a spender is set by a token owner.
    * @param owner The address of the token owner setting the allowance.
    * @param spender The address of the spender for whom the allowance is set.
    * @param amount The amount of tokens the spender is allowed to use.
    */
    event Approved(address indexed owner, address indexed spender, uint256 amount);




    /**
    * @dev Returns the total token supply.
    * @return The total number of tokens in existence.
    */
    function totalSupply() external view returns (uint256);

    /**
    * @dev Returns the token balance of a specific account.
    * @param who The address to query the balance of.
    * @return The number of tokens owned by the passed address.
    */
    function balanceOf(address who) external view returns (uint256);

    /**
    * @dev Approves another address to spend a specific amount of tokens on behalf of msg.sender.
    * @param spender The address which will spend the funds.
    * @param amount The amount of tokens to be spent.
    * @return A boolean value indicating whether the operation succeeded.
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
    * @dev Returns the amount of tokens that an owner has allowed a spender to use.
    * @param owner The address which owns the funds.
    * @param spender The address which will spend the funds.
    * @return The number of tokens still available for the spender.
    */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
    * @dev Transfers tokens from one address to another.
    * @param from The address which you want to send tokens from.
    * @param to The address which you want to transfer tokens to.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean value indicating whether the operation succeeded.
    */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /**
    * @dev Transfers tokens to a specified address.
    * @param to The address to transfer tokens to.
    * @param amount The amount of tokens to be transferred.
    * @return A boolean value indicating whether the operation succeeded.
    */
    function transfer(address to, uint256 amount) external returns (bool);
}