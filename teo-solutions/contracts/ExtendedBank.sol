// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ExtendedBank {
    struct Account {
        bool exists;
        uint256 tokenCounter;
        mapping(address => uint256) tokens;
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
            accounts[msg.sender].tokenCounter == 0,
            "Account should be empty"
        );
        accounts[msg.sender].exists = false;
    }

    function deposit(address _tokenAddress, uint256 _amount)
        external
        accountExists
    {
        accounts[msg.sender].tokens[_tokenAddress] += _amount;
        accounts[msg.sender].tokenCounter += _amount;
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(address _tokenAddress, uint256 _amount)
        external
        accountExists
    {
        require(
            accounts[msg.sender].tokens[_tokenAddress] >= _amount,
            "Not enough tokens"
        );
        accounts[msg.sender].tokens[_tokenAddress] -= _amount;
        accounts[msg.sender].tokenCounter -= _amount;
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    function getBalance(address _tokenAddress)
        external
        view
        accountExists
        returns (uint256 balance)
    {
        return accounts[msg.sender].tokens[_tokenAddress];
    }
}
