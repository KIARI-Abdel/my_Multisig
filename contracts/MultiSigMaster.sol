// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './MultiSigTransactions.sol';

contract MultiSigMaster is MultiSigTransaction {
    event Withdraw(address indexed receiver, uint256 amount);
    event MasterChanged(address indexed master);

    address private Master;


    modifier onlyMaster(address owner) {
        require(owner == Master, "This address doesn't have Master privileges");
        _;
    }

    constructor(
        address master,
        address[] memory _owners,
        uint256 _quorum
        ) public {
        MultiSigTransaction(_owners, _quorum);
        Master = master;
    }

    function getBalance() public onlyMaster(msg.sender) view returns (uint) {
        return address(this).balance;
    }

    function withdraw(address to, uint256 amount) external onlyMaster(msg.sender) returns (bool) {
        (bool sent, bytes memory data) = to.call{ value: amount }("");
        require(sent, "Withdraw transfer failed");
        emit Withdraw(to, amount);
        return sent;
    }
    
    function changeMaster(address newMaster) external onlyMaster(msg.sender) {
        Master = newMaster;
        emit MasterChanged(newMaster);
    }

    function getMaster() external view onlyMaster(msg.sender) returns (address res) {
        res = Master;
    }
}