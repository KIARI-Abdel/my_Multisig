// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './MultiSigAdministration.sol';
import './MultiSigUtils.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Multi-Signature Transaction Contract
 * @dev Contract for handling multi-signature transactions including native and ERC20 token transfers.
 * @notice This contract integrates multi-signature administration features with transaction 
 *         execution logic, supporting both native and ERC20 token transfers.
 */
contract MultiSigTransaction is MultiSigAdministration {    
    using MultiSigUtils for string[];
    using MultiSigUtils for address[];

    /*
     *  Events
     */

    /**
    * @dev Emitted when a transaction is confirmed by an owner.
    * @param sender The address of the owner who confirmed the transaction.
    * @param transactionId The ID of the confirmed transaction.
    */
    event Confirmation(address indexed sender, uint256 transactionId);

    /**
    * @dev Emitted when a transaction confirmation is revoked by an owner.
    * @param sender The address of the owner who revoked the transaction confirmation.
    * @param transactionId The ID of the transaction whose confirmation was revoked.
    */
    event Revocation(address indexed sender, uint256 transactionId);

    /**
    * @dev Emitted when a new transaction is submitted.
    * @param destination The destination address of the transaction.
    * @param transactionId The ID of the submitted transaction.
    */
    event Submission(address indexed destination, uint256 transactionId);

    /**
    * @dev Emitted when a native token transaction is executed.
    * @param amount The amount of native tokens transferred.
    * @param transactionId The ID of the executed transaction.
    */
    event ExecutionNative(uint256 amount, uint256 transactionId);

    /**
    * @dev Emitted when an ERC20 token transaction is executed.
    * @param amount The amount of ERC20 tokens transferred.
    * @param transactionId The ID of the executed transaction.
    */
    event ExecutionERC20(uint256 amount, uint256 transactionId);

    /**
    * @dev Emitted when native tokens are deposited into the contract.
    * @param sender The address of the sender who made the deposit.
    * @param amount The amount of native tokens deposited.
    */
    event Deposit(address indexed sender, uint256 amount);


    /*
     *  Storage
     */
    IERC20 private MyTokenContract;

    mapping(bytes32 => Transaction) public transactions;
    uint256 public transactionCount;
    mapping(bytes32 => mapping(address => uint256)) public confirmations;

    mapping(uint256 => bytes32) public idToHashes;
    bytes32[] public hashesId;
    bytes32 public hashId;

    enum TransactionType { AddOwner, RemoveOwner, ChangeQuorum, SendNative, SendERC20 }

    struct Transaction {
        address destination;
        address submitterAddress;
        uint256 value;
        TransactionType transactionType;
        bool executed;
    }

    /**
    * @dev Ensures that the transaction associated with the given hash exists.
    * @param _hashId The hash ID of the transaction.
    */
    modifier requireTransactionExists(bytes32 _hashId) {
        require(transactions[_hashId].destination != address(0), "There is no transaction associated to this hashId");
        _;
    }

    /**
    * @dev Ensures that the transaction has been confirmed by the required number of owners.
    * @param transactionId The ID of the transaction.
    */
    modifier requireTransactionIsConfirmed(uint256 transactionId) {
        require(isConfirmed(transactionId), "The transaction has not been confirmed by owners yet");
        _;
    }

    /**
    * @dev Ensures that the quorum has been reached for the transaction, either through confirmations or revocations.
    * @param transactionId The ID of the transaction.
    */
    modifier requireQuorumReached(uint256 transactionId) {
        require(isConfirmed(transactionId) || isRevoked(transactionId), "Quorum has not been reached by owners yet");
        _;
    }

    /**
    * @dev Ensures that the transaction associated with the given hash has not already been executed.
    * @param _hashId The hash ID of the transaction.
    */
    modifier requireTransactionNotExecuted(bytes32 _hashId) {
        require(!transactions[_hashId].executed, "The transaction associated with this hash has already been executed");
        _;
    }

    /**
    * @dev Ensures that the given hash does not already exist in the list of transactions.
    * @param _hashId The hash ID to check.
    */
    modifier requireHashDoesntExist(bytes32 _hashId) {
        require(!MultiSigUtils.arrayContainsBytes32(hashesId, _hashId), "This hash already exists");
        _;
    }

    /**
    * @dev Initializes the contract's transactionCount, which serves for Id and initializes administration
    * contract with owners and quorum.
    * @param _owners List of initial owners.
    * @param _quorum The initial quorum requirement for transaction confirmations.
    */
    constructor(
        address[] memory _owners,
        uint256 _quorum
    ) public MultiSigAdministration(_owners, _quorum)  {
        transactionCount = 0;
    }

    /**
    * @dev Allows anyone to deposit native tokens into the contract. Emits a Deposit event.
    */
    function deposit() public payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**
     * @dev Fallback function that is called when none of the other functions match the given function signature,
     * or if Ether is sent to the contract with additional data.
     */
    fallback() external payable {
        deposit();
    }

    /**
     * @dev Fallback function that is called when the contract receives Ether without any other data.
     */
    receive() external payable {
        deposit();
    }

    /**
    * @dev Sets the ERC20 token contract address for the contract.
    * @param tokenContractAddress The address of the ERC20 token contract.
    */
    function setTokenContractAddress(address tokenContractAddress) public requireOwnerExists(msg.sender) {
        MyTokenContract = IERC20(tokenContractAddress);
    }

    /**
    * @dev Allows an owner to submit a new transaction. Emits a Submission event.
    * @param destination The destination address for the transaction.
    * @param value The value (amount of native tokens or token ID) involved in the transaction.
    * @param transactionType The type of transaction being submitted.
    * @return transactionId The ID of the submitted transaction.
    */
    function submitTransaction(
        address destination,
        uint256 value,
        TransactionType transactionType
    ) external requireOwnerExists(msg.sender) returns (uint256 transactionId) {
        hashId = MultiSigUtils.hashData(msg.sender, value, block.timestamp);
        hashesId.push(hashId);
        transactionId = addTransaction(destination, msg.sender, value, transactionType, hashId);
        emit Submission(destination, transactionId);
        //confirmTransaction(transactionId);
    }

    /**
    * @dev Adds a new transaction to the transaction mapping. This function is internal and is called 
    *      within the contract when a new transaction is submitted.
    * @param destination The target address of the transaction.
    * @param submitterAddress The address submitting the transaction.
    * @param value The value (amount of native tokens or token ID) involved in the transaction.
    * @param transactionType The type of transaction being added.
    * @param hashID The unique hash ID of the transaction.
    * @return transactionId The ID of the newly added transaction.
    */
    function addTransaction(
        address destination,
        address submitterAddress,
        uint256 value,
        TransactionType transactionType,
        bytes32 hashID
    ) internal requireAddressIsNotNull(destination) returns (uint256 transactionId) {
        transactionId = transactionCount;
        idToHashes[transactionId] = hashID;
        transactions[hashID] = Transaction({
            destination: destination,
            submitterAddress: submitterAddress,
            value: value,
            transactionType: transactionType,
            executed: false
        });
        transactionCount += 1;
    }

    /**
    * @dev Allows an owner to confirm a transaction. Emits a Confirmation event.
    * @param transactionId The ID of the transaction to be confirmed.
    */
    function confirmTransaction(
        uint256 transactionId
    ) external requireOwnerExists(msg.sender) requireTransactionExists(idToHashes[transactionId]) requireTransactionNotExecuted(idToHashes[transactionId]) {
        hashId = idToHashes[transactionId];
        confirmations[hashId][msg.sender] = 1;
        emit Confirmation(msg.sender, transactionId);
        //executeTransaction(transactionId);
    }

    /**
    * @dev Allows an owner to revoke their confirmation for a transaction. Emits a Revocation event.
    * @param transactionId The ID of the transaction for which the confirmation is to be revoked.
    */
    function revokeTransaction(
        uint256 transactionId
    ) external requireOwnerExists(msg.sender) requireTransactionExists(idToHashes[transactionId]) requireTransactionNotExecuted(idToHashes[transactionId]) {
        hashId = idToHashes[transactionId];
        confirmations[hashId][msg.sender] = 2;
        emit Revocation(msg.sender, transactionId);
    }

    /**
    * @dev Private function to execute a native token transaction. Emits ExecutionNative event.
    * @param transactionId The ID of the transaction to be executed.
    */
    function executeNativeTransaction(uint256 transactionId) internal {
        hashId = idToHashes[transactionId];
        Transaction storage txn = transactions[hashId];

        require(address(this).balance >= txn.value, "Insufficient balance in contract");
        (bool sent, ) = txn.destination.call{value: txn.value}("");
        require(sent, "Failed to send Native token");

        transactions[hashId].executed = true;
        emit ExecutionNative(txn.value, transactionId);
    }

    /**
    * @dev Internal function to transfer ERC20 tokens. Used within executeERC20Transaction.
    * @param from The address from which the tokens will be transferred.
    * @param to The address to which the tokens will be transferred.
    * @param amount The amount of ERC20 tokens to transfer.
    * @return result Indicates whether the transfer was successful.
    */
    function sendERC20(address from, address to, uint256 amount) internal returns (bool result) {
        result = MyTokenContract.transferFrom(from, to, amount);
        require(result, "Transfer ERC20 failed");
    }

    /**
    * @dev Private function to execute an ERC20 token transaction. Emits ExecutionERC20 event.
    * @param transactionId The ID of the transaction to be executed.
    */
    function executeERC20Transaction(uint256 transactionId) internal {
        hashId = idToHashes[transactionId];
        Transaction storage txn = transactions[hashId];

        uint256 allowance = MyTokenContract.allowance(txn.submitterAddress, address(this));
        require(allowance >= txn.value, "Contract is not allowed by user to transfer such amount");
        
        //sendERC20(txn.submitterAddress, txn.destination, txn.value);
        MyTokenContract.transferFrom(txn.submitterAddress, txn.destination, txn.value);
        
        transactions[hashId].executed = true;
        emit ExecutionERC20(txn.value, transactionId);
    }

    /**
    * @dev Executes a confirmed transaction. Determines the type of transaction and executes accordingly.
    * @param transactionId The ID of the transaction to be executed.
    */
    function executeTransaction(
        uint256 transactionId
    ) external requireOwnerExists(msg.sender) requireQuorumReached(transactionId) requireTransactionIsConfirmed(transactionId) requireTransactionNotExecuted(idToHashes[transactionId]) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        Transaction storage txn = transactions[hashId];

        if (isConfirmed(transactionId) && !isRevoked(transactionId)) {
            if (txn.transactionType == TransactionType.AddOwner) {
                addOwner(txn.destination);
            } else if (txn.transactionType == TransactionType.RemoveOwner) {
                removeOwner(txn.destination);
            } else if (txn.transactionType == TransactionType.ChangeQuorum) {
                changeQuorum(txn.value);
            } else if (txn.transactionType == TransactionType.SendNative) {
                executeNativeTransaction(transactionId);
            } else if (txn.transactionType == TransactionType.SendERC20) {
                executeERC20Transaction(transactionId);
            }
        }
    }

    function getTokenBalance() public view returns (uint256 bal) {
        bal = MyTokenContract.allowance(msg.sender, address(this));
    }

    /**
    * @dev Checks if a transaction has reached the required quorum of confirmations.
    * @param transactionId The ID of the transaction to check.
    * @return res `true` if the transaction is confirmed, `false` otherwise.
    */
    function isConfirmed(uint256 transactionId) public returns (bool res) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        uint256 count = 0;
        res = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[hashId][owners[i]] == 1) count += 1;
            if (count >= quorum) {
                res = true;
                return res;
            }
        }
        return res;
    }

    /**
    * @dev Checks if a transaction has reached the required quorum of revokations.
    * @param transactionId The ID of the transaction to check.
    * @return res `true` if the transaction is revoked, `false` otherwise.
    */
    function isRevoked(uint256 transactionId) public returns (bool res) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        uint256 count = 0;
        res = false;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[hashId][owners[i]] == 2) count += 1;
            if (count >= quorum) {
                res = true;
                return res;
            }
        }
        return res;
    }

    /**
    * @dev Checks if an owner has confirmed a transaction or not (revoked or not voted yet).
    * @param transactionId The ID of the transaction to check.
    * @param owner The address of the owner whose confirmation status is to be checked.
    * @return `true` if the owner has confirmed, `false` otherwise.
    */
    function getUserConfirmationStatus(uint256 transactionId, address owner) external returns (bool) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        uint256 res = confirmations[hashId][owner];
        if (res == 1) return true;
        return false;
    }

    /**
    * @dev Returns the number of confirmations for a transaction.
    * @param transactionId The ID of the transaction.
    * @return count : The count of confirmations for the transaction.
    */
    function getConfirmationCount(uint256 transactionId) external returns (uint256 count) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        for (uint256 i = 0; i < owners.length; i++) if (confirmations[hashId][owners[i]] == 1) count += 1;
    }

    /**
    * @dev Returns the number of revocations for a transaction.
    * @param transactionId The ID of the transaction.
    * @return count : The count of revocations for the transaction.
    */
    function getRevocationCount(uint256 transactionId) external returns (uint256 count) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        for (uint256 i = 0; i < owners.length; i++) if (confirmations[hashId][owners[i]] == 2) count += 1;
    }

    /**
    * @dev Returns the total number of transactions submitted to the contract.
    * @return count : The total count of transactions.
    */
    function getTransactionCount() external view returns (uint256 count) {
        count = transactionCount;
    }

    /**
    * @dev Returns an array of addresses that have confirmed a given transaction.
    * @param transactionId The ID of the transaction.
    * @return _confirmations : A list of addresses that have confirmed the transaction.
    */
    function getConfirmations(uint256 transactionId) external returns (address[] memory _confirmations) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[hashId][owners[i]] == 1) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }

    /**
    * @dev Returns an array of addresses that have revoked a given transaction.
    * @param transactionId The ID of the transaction.
    * @return _confirmations : A list of addresses that have revoked their confirmation for the transaction.
    */
    function getRevocations(uint256 transactionId) external returns (address[] memory _confirmations) {
        hashId = idToHashes[transactionId];
        require(MultiSigUtils.arrayContainsBytes32(hashesId, hashId), "No transaction found associated with this Id");
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[hashId][owners[i]] == 2) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }
}