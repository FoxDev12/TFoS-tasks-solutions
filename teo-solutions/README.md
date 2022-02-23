# Tasks from "The Fellowship of Solidity" Discord server

## Bank

Make an ETH bank then, users can open an account (only if they dont have one already), close it (only if its empty), deposit ETH, withdraw what they deposited or part of it.

## Extended Bank

Let's extend the bank a little. It now must be compatible with any ERC20 token, users must be able to deposit and withdraw both ETH and (any) ERC20 tokens (we're not taking into account potential malicious user input or edge cases such as fee on transfer tokens). This is a little harder than just implementing the IERC20 interface since you now have to keep track of multiple balances for each account.

