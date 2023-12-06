// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './IERC20.sol';

/**
 * @title ERC20 Base token Contract
 */
abstract contract ERC20Base is IERC20 {
    /*
     *  Storage
     */
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
    * @dev Initializes the contract with a name, symbol, and decimals for the ERC20 token.
    * @notice This is an abstract contract used as a base for creating ERC20 tokens.
    * @param name The name of the ERC20 token.
    * @param symbol The symbol of the ERC20 token.
    * @param decimals The number of decimals used to get its user representation.
    */
    constructor (string memory name, string memory symbol, uint8 decimals) internal {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}