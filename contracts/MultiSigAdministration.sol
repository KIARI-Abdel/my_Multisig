// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title Multi-Signature Administration Contract
 * @dev Contract to manage owners and quorum requirements for a multi-signature setup. 
 *         Initializable for upgradeable contract patterns.
 * @notice This contract provides functionality to add or remove owners and change 
 *         quorum requirements for a multi-signature contract.
 */
contract MultiSigAdministration {
    /*
     *  Events
     */

    /**
    * @dev Emitted when a new owner is added to the contract.
    * @param owner The address of the newly added owner.
    */
    event OwnerAddition(address indexed owner);

    /**
    * @dev Emitted when an owner is removed from the contract.
    * @param owner The address of the owner being removed.
    */
    event OwnerRemoval(address indexed owner);

    /**
    * @dev Emitted when the quorum requirement is changed.
    * @param quorum The new quorum requirement.
    */
    event QuorumChanged(uint256 quorum);

    /*
     *  Storage
     */
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public quorum;

    /**
    * @dev Ensures that the function is only callable by the contract itself.
    */
    modifier requireOnlyWallet() {
        require(msg.sender == address(this), "Only accessible from this contract itself");
        _;
    }

    /**
    * @dev Ensures that the provided address is not already an owner.
    * @param owner The address to be checked.
    */
    modifier requireOwnerDoesNotExist(address owner) {
        require(!isOwner[owner], "This address is already an owner");
        _;
    }

    /**
    * @dev Ensures that the provided address is an existing owner.
    * @param owner The address to be verified.
    */
    modifier requireOwnerExists(address owner) {
        require(isOwner[owner], "This address is not an owner");
        _;
    }

    /**
    * @dev Ensures that the provided address is not the zero address.
    * @param _address The address to be checked.
    */
    modifier requireAddressIsNotNull(address _address) {
        require(_address != address(0), "The address is null");
        _;
    }

    /**
    * @dev Ensures that the quorum is not greater than the number of owners and both are non-zero.
    * @param ownerCount The number of owners.
    * @param _quorum The quorum requirement to be validated.
    */
    modifier validRequirement(uint256 ownerCount, uint256 _quorum) {
        require(_quorum <= ownerCount && _quorum != 0 && ownerCount != 0, "Conditions are not met");
        _;
    }

    /**
    * @dev Initializes the contract with a set of owners and a quorum requirement.
    * @param _owners List of initial owners.
    * @param _quorum The initial quorum requirement.
    */
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

    /**
    * @dev Adds a new owner to the contract. Restricted to existing owners.
    * @param owner The address to be added as a new owner.
    */
    function addOwner(
        address owner
    ) public requireOwnerDoesNotExist(owner) requireOwnerExists(msg.sender) requireAddressIsNotNull(owner) validRequirement(owners.length + 1, quorum) {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    /**
    * @dev Removes an existing owner from the contract. Restricted to existing owners.
    * @param owner The address of the owner to be removed.
    */
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

    /**
    * @dev Changes the quorum requirement. Restricted to existing owners.
    * @param newQuorum The new quorum requirement.
    */
    function changeQuorum(uint256 newQuorum) public requireOwnerExists(msg.sender) validRequirement(owners.length, newQuorum) {
        quorum = newQuorum;
        emit QuorumChanged(newQuorum);
    }

    /**
    * @dev Returns the list of current owners.
    * @return The current list of owner addresses.
    */
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    /**
    * @dev Checks if a given address is an owner of the contract.
    * @param addressToVerify The address to be verified.
    * @return res : `true` if the address is an owner, `false` otherwise.
    */
    function verifyOwner(address addressToVerify) external view returns (bool res) {
        res = isOwner[addressToVerify];
    }

    /**
    * @dev Returns the current quorum requirement.
    * @return res : The current quorum requirement.
    */
    function getQuorum() public view returns (uint256 res) {
        res = quorum;
    }

    /**
    * @dev Returns the total number of owners.
    * @return res : The total number of owners.
    */
    function getOwnerCount() external view returns (uint256 res) {
        res = owners.length;
    }
}