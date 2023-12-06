// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


/**
 * @title Multi-Signature Utilities Library
 * @dev Provides utility functions for multi-signature contract operations.
 * @notice This library includes functions for array manipulation and data hashing, 
 *         specifically designed to support multi-signature contract functionalities.
 */
library MultiSigUtils {

    /**
    * @dev Checks if an array of strings contains a specific string.
    * @param arrayToCheck The array of strings to be checked.
    * @param searchedString The string to search for in the array.
    * @return result `true` if the array contains the searched string, `false` otherwise.
    */
    function arrayContainsString(string[] memory arrayToCheck, string memory searchedString) internal pure returns (bool result) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (keccak256(bytes(searchedString)) == keccak256(bytes(arrayToCheck[i]))) return true;
        }
        return false;
    }

    /**
    * @dev Checks if an array of bytes32 contains a specific bytes32 element.
    * @param arrayToCheck The array of bytes32 to be checked.
    * @param searchedBytes32 The bytes32 element to search for in the array.
    * @return `true` if the array contains the searched bytes32 element, `false` otherwise.
    */
    function arrayContainsBytes32(bytes32[] memory arrayToCheck, bytes32 searchedBytes32) internal pure returns (bool) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (arrayToCheck[i] == searchedBytes32) {
                return true;
            }
        }
        return false;
    }

    /**
    * @dev Checks if an array of addresses contains a specific address.
    * @param arrayToCheck The array of addresses to be checked.
    * @param searchedAddress The address to search for in the array.
    * @return `true` if the array contains the searched address, `false` otherwise.
    */
    function arrayContainsAddress(address[] memory arrayToCheck, address searchedAddress) internal pure returns (bool) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (arrayToCheck[i] == searchedAddress) return true;
        }
        return false;
    }

    /**
    * @dev Retrieves the position of a string in an array.
    * @param arrayToCheck The array of strings to be checked.
    * @param searchedStringPosition The string whose position is to be found.
    * @return pos The position of the string in the array.
    */
    function getElementPositionInArray(string[] memory arrayToCheck, string memory searchedStringPosition) internal view returns (uint256 pos) {
        require(arrayContainsString(arrayToCheck, searchedStringPosition), "The element doesn't exist in the array");
        for (pos = 0; pos < arrayToCheck.length; pos++) {
            if (keccak256(bytes(searchedStringPosition)) == keccak256(bytes(arrayToCheck[pos]))) return pos;
        }
    }

    /**
    * @dev Generates a SHA256 hash from user address, transaction value, and transaction date.
    * @param user The address of the user involved in the transaction.
    * @param amount The transaction amount.
    * @param date The date of the transaction.
    * @return The resulting SHA256 hash.
    */
    function hashData(address user, uint256 amount, uint256 date) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, amount, date));
    }

    /**
    * @dev Converts a bytes32 value to a hexadecimal string.
    * @param _bytes The bytes32 value to convert.
    * @return A string representing the hexadecimal form of the input bytes32.
    */
    function bytes32ToHexString(bytes32 _bytes) internal pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory hexString = new bytes(64); // 32 bytes * 2 characters per byte
        for (uint i = 0; i < 32; i++) {
            hexString[i*2] = hexChars[uint8(_bytes[i] >> 4)];
            hexString[i*2 + 1] = hexChars[uint8(_bytes[i] & 0x0f)];
        }
        return string(hexString);
    }
}