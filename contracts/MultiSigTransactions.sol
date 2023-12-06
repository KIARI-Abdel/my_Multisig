// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './MultiSigAdministration.sol';
import './MultiSigUtils.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MultiSigTransaction is MultiSigAdministration {    
    using MultiSigUtils for string[];
    using MultiSigUtils for address[];

    event Confirmation(address indexed sender, uint256 transactionId);
    event Revocation(address indexed sender, uint256 transactionId);
    event Submission(address indexed destination, uint256 transactionId);
    event ExecutionNative(uint256 amount, uint256 transactionId);
    event ExecutionERC20(uint256 amount, uint256 transactionId);
    event Deposit(address indexed sender, uint256 amount);

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

    modifier requireTransactionExists(bytes32 _hashId) {
        require(transactions[_hashId].destination != address(0), "There is no transaction associated to this hashId");
        _;
    }

    modifier requireTransactionIsConfirmed(uint256 transactionId) {
        require(isConfirmed(transactionId), "The transaction has not been confirmed by owners yet");
        _;
    }

    modifier requireQuorumReached(uint256 transactionId) {
        require(isConfirmed(transactionId) || isRevoked(transactionId), "Quorum has not been reached by owners yet");
        _;
    }

    modifier requireTransactionNotExecuted(bytes32 _hashId) {
        require(!transactions[_hashId].executed, "The transaction associated with this hash has already been executed");
        _;
    }

    modifier requireHashDoesntExist(bytes32 _hashId) {
        require(!MultiSigUtils.arrayContainsBytes32(hashesId, _hashId), "This hash already exists");
        _;
    }

    constructor(
        address[] memory _owners,
        uint256 _quorum
    ) public validRequirement(_owners.length, _quorum) {
        MultiSigAdministration(_owners, _quorum);
        transactionCount = 0;
    }

    function deposit() public payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    fallback() external payable {
        deposit();
    }

    function setTokenContractAddress(address tokenContractAddress) public requireOwnerExists(msg.sender) {
        MyTokenContract = IERC20(tokenContractAddress);
    }

    function submitTransaction(
        address destination,
        uint256 value,
        TransactionType transactionType
    ) external requireOwnerExists(msg.sender) returns (uint256 transactionId) {
        hashId = MultiSigUtils.hashData(msg.sender, value, block.timestamp);
        hashesId.push(hashId);
        transactionId = addTransaction(destination, msg.sender, value, transactionType, hashId);
        emit Submission(destination, transactionId);
    }

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

    function confirmTransaction(
        uint256 transactionId
    ) external requireOwnerExists(msg.sender) requireTransactionExists(idToHashes[transactionId]) requireTransactionNotExecuted(idToHashes[transactionId]) {
        hashId = idToHashes[transactionId];
        confirmations[hashId][msg.sender] = 1;
        emit Confirmation(msg.sender, transactionId);
    }

    function revokeTransaction(
        uint256 transactionId
    ) external requireOwnerExists(msg.sender) requireTransactionExists(idToHashes[transactionId]) requireTransactionNotExecuted(idToHashes[transactionId]) {
        hashId = idToHashes[transactionId];
        confirmations[hashId][msg.sender] = 2;
        emit Revocation(msg.sender, transactionId);
    }

    function executeNativeTransaction(uint256 transactionId) internal {
        hashId = idToHashes[transactionId];
        Transaction storage txn = transactions[hashId];

        require(address(this).balance >= txn.value, "Insufficient balance in contract");
        (bool sent, ) = txn.destination.call{value: txn.value}("");
        require(sent, "Failed to send Native token");

        transactions[hashId].executed = true;
        emit ExecutionNative(txn.value, transactionId);
    }

    function sendERC20(address from, address to, uint256 amount) internal returns (bool result) {
        result = MyTokenContract.transferFrom(from, to, amount);
        require(result, "Transfer ERC20 failed");
    }

    function executeERC20Transaction(uint256 transactionId) internal {
        hashId = idToHashes[transactionId];
        Transaction storage txn = transactions[hashId];

        uint256 allowance = MyTokenContract.allowance(txn.submitterAddress, address(this));
        require(allowance >= txn.value, "Contract is not allowed by user to transfer such amount");
        
        sendERC20(txn.submitterAddress, txn.destination, txn.value);
        
        transactions[hashId].executed = true;
        emit ExecutionERC20(txn.value, transactionId);
    }

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
}