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

    mapping(address => mapping(address => uint256)) public tokensLentAmount;
    mapping(address => mapping(address => uint256)) public tokensBorrowedAmount;

    mapping(uint256 => mapping(address => address)) public tokensLent;
    mapping(uint256 => mapping(address => address)) public tokensBorrowed;


    //EVENTS
    

    struct Token{
        address tokenAddress;
        uint256 LTV;
        uint256 stableRate;
        string name;
    }
    Token[] public tokensForLending;
    Token[] public tokensForBorrowing;

    IERC20 public larToken;

    uint256 public noOfTokensLent = 0;
    uint256 public noOfTokensBorrowed = 0;

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

    function lend(
        address tokenAddress, 
        uint256 amount
    ) external payable {
        require(tokenIsAllowed(tokenAddress, tokensForLending));
        require(amount > 0);
        
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(msg.sender) >= amount);

        token.transferFrom(msg.sender, address(this), amount);

        (bool userPresent, int256 userIndex) = msg.sender.isUserPresentIn(lenders);

        if (userPresent) {
            updateUserTokenBorrowedOrLent(tokenAddress, amount, userIndex, "lenders");
        } else {
            lenders.push(msg.sender);
            tokensLentAmount[tokenAddress][msg.sender] = amount;
            tokensLent[noOfTokensLent++][msg.sender] = tokenAddress;
        }

        larToken.transfer(msg.sender, getAmountInDollars(amount, tokenAddress));
    }

    function borrow() external {}

    function payDept() external {}

    function withdraw() external {}

    function getAmountInDollars(
        uint256 amount, 
        address tokenAddress
    ) public view returns (uint256) {}

    function updateUserTokenBorrowedOrLent(
        address tokenAddress,
        uint256 amount,
        int256 userIndex,
        string memory lendersOrBorrowers
    ) private {
        if (keccak256(abi.encodePacked(lendersOrBorrowers)) == keccak256(abi.encodePacked("lenders"))) {
            address currentUser = lenders[uint256(userIndex)];

            if (hasLentOrBorrowedToken(currentUser, tokenAddress, noOfTokensLent, "tokensLent")) {
                tokensLentAmount[tokenAddress][currentUser] += amount;
            } else {
                tokensLent[noOfTokensLent++][currentUser] = tokenAddress;
                tokensLentAmount[tokenAddress][currentUser] = amount;
            }
        } else if (keccak256(abi.encodePacked(lendersOrBorrowers)) == keccak256(abi.encodePacked("borrowers"))) {
            address currentUser = borrowers[uint256(userIndex)];

            if (hasLentOrBorrowedToken(currentUser, tokenAddress, noOfTokensLent, "tokensBorrowed")) {
                tokensBorrowedAmount[tokenAddress][currentUser] += amount;
            } else {
                tokensBorrowed[noOfTokensLent++][currentUser] = tokenAddress;
                tokensBorrowedAmount[tokenAddress][currentUser] = amount;
            }
        } 
    }

    function hasLentOrBorrowedToken(
        address currentUser,
        address tokenAddress,
        uint256 noOfTokensLentOrBorrowed,
        string memory _tokenLentOrBorrowed
    ) public view returns (bool) {}

    // CHECKERS
    function tokenIsAllowed(address tokenAddress, Token[] memory tokenArray) private pure returns (bool) {
        if (tokenArray.length > 0) {
            for (uint256 i=0; i < tokenArray.length; i++) {
                if (tokenArray[i].tokenAddress == tokenAddress) {
                    return true;
                }
            }
        }
        return false;
    }

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

    function getTotalTokenSupplied(address tokenAddress) public view returns (uint256) {
        uint256 totalTokenSupplied = 0;
        if (lenders.length > 0) {
            for (uint256 i=0; i < lenders.length; i++) {
                totalTokenSupplied += tokensLentAmount[tokenAddress][lenders[i]];
            }
        }
        return totalTokenSupplied;
    }

    function getTotalTokenBorrowed(address tokenAddress) public view returns (uint256) {
        uint256 totalTokenBorrowed = 0;
        if (lenders.length > 0) {
            for (uint256 i=0; i < lenders.length; i++) {
                totalTokenBorrowed += tokensBorrowedAmount[tokenAddress][lenders[i]];
            }
        }
        return totalTokenBorrowed;
    }

}