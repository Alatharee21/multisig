// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultiSig {

    receive() external payable{}
    
    address[] public owners;
    uint public transactionCount;
    uint public required;

    struct Transaction {
        address destination;
        uint value;
        bool executed;
        bytes data;
    }
    
    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;

    function executeTransaction(uint256 _id) public {
        require(isConfirmed(_id) == true);

        address tDestination = transactions[_id].destination;
        uint256 tValue = transactions[_id].value;
        bytes memory tData = transactions[_id].data;

        (bool success, ) = tDestination.call{value: tValue}(tData);
        require(success);
        
        transactions[_id].executed = true;
    }

    function isConfirmed(uint256 _ID) public view returns(bool){
        if(getConfirmationsCount(_ID) == required){
            return true;
        }
        return false;
    }

    function submitTransaction(address _destination, uint256 _value, bytes memory data) external {
        confirmTransaction(addTransaction(_destination, _value, data));
    }

    function getConfirmationsCount(uint transactionId) public view returns(uint) {
        uint count;
        for(uint i = 0; i < owners.length; i++) {
            if(confirmations[transactionId][owners[i]]) {
                count++;
            }
        }
        return count;
    }

    function isOwner(address addr) private view returns(bool) {
        for(uint i = 0; i < owners.length; i++) {
            if(owners[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function confirmTransaction(uint transactionId) public {
        require(isOwner(msg.sender));
        
        confirmations[transactionId][msg.sender] = true;

        if(getConfirmationsCount(transactionId) == required){
        executeTransaction(transactionId);
        }
    }

    function addTransaction(address destination, uint value, bytes memory data) internal returns(uint) {
        transactions[transactionCount] = Transaction(destination, value, false, data);
        transactionCount += 1;
        return transactionCount - 1;
    }

    constructor(address[] memory _owners, uint _confirmations) {
        require(_owners.length > 0);
        require(_confirmations > 0);
        require(_confirmations <= _owners.length);
        owners = _owners;
        required = _confirmations;
    }
}
