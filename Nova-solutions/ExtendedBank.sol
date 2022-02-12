
import "./deps/ExtendedBank/IERC20.sol";
//SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.11;
contract ExtendedBank {
    struct Account{
        bool exists;
        address[] tokenAddresses;
        // Two synced arrays would be cheaper. Will probably change this in a future update
        mapping(address => uint256) balances;
    }
    mapping(address => Account) private accounts;
    modifier accountExists {
        require(accounts[msg.sender].exists, "ExtendedBank: No account found for this address");
        _;
    }
    // Here, we will be storing the ether balance as if it was any other ERC20 token, except we'll use address(0), 
    // If the user inputs address(0) in the tokenAddress field, then `amount` will be ignored and msg.value will be used instead.
    // The deposit and withdraw function work in the same way. 
    function openAccount(address tokenAddress, uint256 amount) external payable {
        require(!accounts[msg.sender].exists, "ExtendedBank: Account already exists");
        // Setting the balance to msg.value instead of adding it to the previous balance is ok since this is the first deposit. And it saves gas
        accounts[msg.sender].exists = true;
        if(tokenAddress == address(0)) {
        accounts[msg.sender].balances[address(0)] = msg.value;
        accounts[msg.sender].exists = true;
        }
        else {
            // Mitigation, another solution would be to always add msg.value to balances[address(0)], but it cost more gas in most cases.
            require(msg.value == 0, "Do not send ether when trying to deposit other ERC20 tokens at the same time");
            accounts[msg.sender].balances[tokenAddress] = amount;
            IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        }
    }
    
    function deposit(address tokenAddress, uint256 amount) external payable accountExists {
        if(tokenAddress == address(0)) {
            accounts[msg.sender].balances[address(0)] += msg.value;
        }
        else {
            require(msg.value == 0, "Do not send ether when trying to deposit other ERC20 tokens at the same time");
            accounts[msg.sender].balances[tokenAddress] += amount;
            if(tokenExists(msg.sender, tokenAddress) == false) {
                accounts[msg.sender].tokenAddresses.push(tokenAddress);
            }
                IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        }
    }

    function tokenExists(address account, address tokenAddress) internal view returns(bool) {
        bool found;
        for(uint i; i < accounts[account].tokenAddresses.length; i++) {
            if (accounts[account].tokenAddresses[i] == tokenAddress) {
                found = true;
                break;
            }
        }
        return found;
    }

    function withdraw(address tokenAddress, uint256 amount) external accountExists {
        // If user tries to withdraw more than what he deposited, simply transfer them all their balance. 
        if(amount > accounts[msg.sender].balances[tokenAddress]) {
            amount = accounts[msg.sender].balances[tokenAddress];
        }
        // Sets the amount BEFORE transferring out to prevent exploits (for more info, look up reentrancy attacks and the check-effect-interaction pattern)
        accounts[msg.sender].balances[tokenAddress] -= amount;
        if (tokenAddress == address(0)) {
        (bool success,) = payable(msg.sender).call{value : amount}("");
        require(success, "something went wrong, try again");
        }
        else {
            IERC20(tokenAddress).transfer(msg.sender, amount);
        }
    }

    function closeAccount() external accountExists {
        for(uint i; i < accounts[msg.sender].tokenAddresses.length; i++) {
            if (accounts[msg.sender].balances[accounts[msg.sender].tokenAddresses[i]] != 0) {
                revert("ExtendedBank: Account not empty");
            }
        }
        accounts[msg.sender].exists = false;
    }
    
    function getBalance(address account, address tokenAddress) external view accountExists returns(uint256 balance) {
        return(accounts[account].balances[tokenAddress]);
    } 
}