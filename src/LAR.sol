// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LAR is ERC20 {

    constructor() ERC20("LAR Token", "LAR") {
        _mint(msg.sender, 100000 * 10 **decimals());
    }
}