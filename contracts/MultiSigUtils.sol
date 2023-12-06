// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


/**
 * @title Multi-Signature Utilities Library
 * @dev Provides utility functions for multi-signature contract operations.
 * @notice This library includes functions for array manipulation and data hashing, 
 *         specifically designed to support multi-signature contract functionalities.
 */
library MultiSigUtils {
    function arrayContainsString(string[] memory arrayToCheck, string memory searchedString) internal pure returns (bool result) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (keccak256(bytes(searchedString)) == keccak256(bytes(arrayToCheck[i]))) return true;
        }
        return false;
    }

    function arrayContainsAddress(address[] memory arrayToCheck, address searchedAddress) internal pure returns (bool) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (arrayToCheck[i] == searchedAddress) return true;
        }
        return false;
    }
}