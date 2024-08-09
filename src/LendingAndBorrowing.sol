// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LendingHelper.sol";

contract LendingAndBorrowing is Ownable{
    using LendingHelper for address;


    IERC20 public larToken;

    constructor(address _token) {
        larToken = IERC20(_token);
    }
}