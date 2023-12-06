// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MultiSigAdministration {
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event QuorumChanged(uint256 quorum);

    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public quorum;


    modifier requireOwnerDoesNotExist(address owner) {
        require(!isOwner[owner], "This address is already an owner");
        _;
    }

    modifier requireOwnerExists(address owner) {
        require(isOwner[owner], "This address is not an owner");
        _;
    }

    modifier requireAddressIsNotNull(address _address) {
        require(_address != address(0), "The address is null");
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _quorum) {
        require(_quorum <= ownerCount && _quorum != 0 && ownerCount != 0, "Conditions are not met");
        _;
    }

    constructor(
        address[] memory _owners,
        uint256 _quorum
    ) public validRequirement(_owners.length, _quorum) {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0), "Address shouldn't be already listed as owner, nor should it be NULL");
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        quorum = _quorum;
    }

    function addOwner(
        address owner
    ) public requireOwnerDoesNotExist(owner) requireOwnerExists(msg.sender) requireAddressIsNotNull(owner) validRequirement(owners.length + 1, quorum) {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    function removeOwner(address owner) public requireOwnerExists(msg.sender) requireOwnerExists(owner) {
        require(owners.length > 1, "Can't remove last owner");
        if (quorum > owners.length - 1) changeQuorum(owners.length - 1);
        for (uint256 i = 0; i < owners.length - 1; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        }
        isOwner[owner] = false;
        owners.pop();
        emit OwnerRemoval(owner);
    }

    function changeQuorum(uint256 newQuorum) public requireOwnerExists(msg.sender) validRequirement(owners.length, newQuorum) {
        quorum = newQuorum;
        emit QuorumChanged(newQuorum);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function verifyOwner(address addressToVerify) external view returns (bool res) {
        res = isOwner[addressToVerify];
    }

    function getQuorum() public view returns (uint256 res) {
        res = quorum;
    }

    function getOwnerCount() external view returns (uint256 res) {
        res = owners.length;
    }
}