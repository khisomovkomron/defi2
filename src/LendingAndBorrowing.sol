// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LendingHelper.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// import {AggregatorV3Interface} from "../lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract LendingAndBorrowing{
    using LendingHelper for address;

    //VARIABLES
    address private owner;
    address[] public lenders;
    address[] public borrowers;

    // MAPPINGS 
    mapping(address => address) public tokenToPriceFeed;

    //EVENTS
    

    struct Token{
        address tokenAddress;
        uint256 LTV;
        uint256 stableRate;
        string name;
    }

    IERC20 public larToken;

    Token[] public tokensForLending;
    Token[] public tokensForBorrowing;

    // CONSTRUCTOR
    constructor(address _token) {
        larToken = IERC20(_token);
        owner = msg.sender;
    }

    //MODIFIERS 
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not Owner!");
        _;
    }

    function addTokensForLending(
        string memory name,
        address tokenAddress,
        uint256 LTV,
        uint256 borrowStableRate
    ) external onlyOwner {
        Token memory token = Token(tokenAddress, LTV, borrowStableRate, name);

        if (!tokenIsAlreadyThere(token, tokensForLending)) {
            tokensForLending.push(token);
        }
    }

    function addTokensForBorrowing(
        string memory name,
        address tokenAddress,
        uint256 LTV,
        uint256 borrowStableRate
    ) external onlyOwner {
        Token memory token = Token(tokenAddress, LTV, borrowStableRate, name);

        if (!tokenIsAlreadyThere(token, tokensForBorrowing)) {
            tokensForBorrowing.push(token);
        }
    }

    function addTokenToPriceFeedMapping(
        address tokenAddress,
        address tokenToUsdPriceFeed
    ) external onlyOwner {
        tokenToPriceFeed[tokenAddress] = tokenToUsdPriceFeed;
    }

    function lend() external payable {}

    function borrow() external {}

    function payDept() external {}

    function withdraw() external {}

    // CHECKERS

    function tokenIsAlreadyThere(Token memory token, Token[] memory tokenArray) private pure returns (bool) {
        if (tokenArray.length > 0) {
            for (uint256 i=0; i < tokenArray.length; i++) {
                if (tokenArray[i].tokenAddress == token.tokenAddress) {
                    return true;
                }
            }
        }
        return false;
    }

    // GETTERS 

    function getLendersArray() public view returns (address[] memory) {
        return lenders;
    }

    function getBorrowersArray() public view returns (address[] memory) {
        return borrowers;
    }

    function getTokensForLendingArray() public view returns (Token[] memory) {
        return tokensForLending;
    }

    function getTokensForBorrowingArray() public view returns (Token[] memory) {
        return tokensForBorrowing;
    }

}