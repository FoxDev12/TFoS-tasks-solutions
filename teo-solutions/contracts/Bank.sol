// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Bank {
    struct Account {
        uint256 tokenBalance;
        bool exists;
    }

    mapping(address => Account) private accounts;

    modifier accountExists() {
        require(accounts[msg.sender].exists, "You don't have an account");
        _;
    }

    function openAccount() external {
        require(!accounts[msg.sender].exists, "You already have an account");
        accounts[msg.sender].exists = true;
    }

    function closeAccount() external accountExists {
        require(
            accounts[msg.sender].tokenBalance == 0,
            "Account should be empty"
        );
        accounts[msg.sender].exists = false;
    }

    function deposit() external payable accountExists {
        accounts[msg.sender].tokenBalance += msg.value;
    }

    function withdraw(uint256 _amount) external accountExists {
        require(
            accounts[msg.sender].tokenBalance >= _amount,
            "Insufficient balance"
        );
        accounts[msg.sender].tokenBalance -= _amount;
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdraw failed, try again");
    }

    function viewAccountBalance() external view returns (uint256) {
        return accounts[msg.sender].tokenBalance;
    }
}
