// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is Context, ERC20 {
    constructor() ERC20("TestToken", "TEST") {
        _mint(msg.sender, 10000 * (10**uint256(decimals())));
    }
}
