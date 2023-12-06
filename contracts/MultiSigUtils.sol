// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

library MultiSigUtils {
    function arrayContainsString(string[] memory arrayToCheck, string memory searchedString) internal pure returns (bool result) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (keccak256(bytes(searchedString)) == keccak256(bytes(arrayToCheck[i]))) return true;
        }
        return false;
    }

    function arrayContainsBytes32(bytes32[] memory arrayToCheck, bytes32 searchedBytes32) internal pure returns (bool) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (arrayToCheck[i] == searchedBytes32) {
                return true;
            }
        }
        return false;
    }

    function arrayContainsAddress(address[] memory arrayToCheck, address searchedAddress) internal pure returns (bool) {
        for (uint256 i = 0; i < arrayToCheck.length; i++) {
            if (arrayToCheck[i] == searchedAddress) return true;
        }
        return false;
    }

    function getElementPositionInArray(string[] memory arrayToCheck, string memory searchedStringPosition) internal view returns (uint256 pos) {
        require(arrayContainsString(arrayToCheck, searchedStringPosition), "The element doesn't exist in the array");
        for (pos = 0; pos < arrayToCheck.length; pos++) {
            if (keccak256(bytes(searchedStringPosition)) == keccak256(bytes(arrayToCheck[pos]))) return pos;
        }
    }

    function hashData(address user, uint256 amount, uint256 date) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, amount, date));
    }

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