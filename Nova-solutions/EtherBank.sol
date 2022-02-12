//SPDX-License-Identifier: WTFPL

pragma solidity ^0.8.11;
contract EtherBank {
    struct Account{
        bool exists;
        uint256 balance;
    }
    mapping(address => Account) private accounts;
    modifier accountExists {
        require(accounts[msg.sender].exists, "EtherBank: No account found for this address");
        _;
    }
    function openAccount() external payable {
        require(!accounts[msg.sender].exists, "EtherBank: Account already exists");
        // Setting the balance to msg.value instead of adding it to the previous balance is ok since this is the first deposit. And it saves gas
        accounts[msg.sender].balance = msg.value;
        accounts[msg.sender].exists = true;
    }
    function deposit() external payable accountExists {
        accounts[msg.sender].balance += msg.value;        
    }
    function withdraw(uint256 amount) external accountExists {
        if(amount > accounts[msg.sender].balance) {
            amount = accounts[msg.sender].balance;
        }
        // Sets the amount before transferring ether out to prevent exploits (for more info, look up reentrancy attacks and the check-effect-interaction pattern)
        accounts[msg.sender].balance -= amount;
        (bool success,) = payable(msg.sender).call{value : amount}("");
        require(success, "something went wrong, try again");
    }

    function closeAccount() external accountExists {
        require(accounts[msg.sender].balance == 0, "EtherBank: account not empty yet, withdraw first");
        accounts[msg.sender].exists = false;
    }
    function viewAccountBalance(address account) external view accountExists returns(uint256 balance) {
        return(accounts[account].balance);
    }
}