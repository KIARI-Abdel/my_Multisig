// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './ERC20Base.sol';
import './ERC20Pausable.sol';

/**
 * @title MyToken
 * @dev Implementation of an ERC20 token with additional pausable functionality. 
 *      Inherits from ERC20Pausable and ERC20Base.
 * @notice MyToken is an example contract that combines standard ERC20 capabilities 
 *         with the ability to pause and resume token transfers. It initializes with 
 *         a specified name, symbol, decimals, and total supply.
 */
contract MyToken is ERC20Pausable, ERC20Base {

    /**
    * @dev Initializes the contract with token details and an initial total supply.
    * @param name The name of the token.
    * @param symbol The symbol of the token.
    * @param decimals The number of decimals used to get its user representation.
    * @param totalSupply The initial total supply of tokens, minted to the creator of the contract.
    */
    constructor (string memory name, string memory symbol, uint8 decimals, uint256 totalSupply)
    public
    ERC20Base (name, symbol, decimals) {
        _mint(msg.sender, totalSupply);
    }
}