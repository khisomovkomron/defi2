// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ADE is ERC20 {

    constructor() ERC20("ADE TOKEN", "ADE") {
        _mint(msg.sender, 10000000 * 10**decimals());
    }
}