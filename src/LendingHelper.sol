// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



library LendingHelper {

    function isUserPresentIn(address userAddress, address[] memory users) internal pure returns (bool, int256) {
        if (users.length > 0) {
            for (uint256 i =0; i < users.length; i++) {
                if (userAddress == users[i]) {
                    return (true, int256(i));
                }
            }
        }
        return (false, -1);
    }

    function indexOf(address user, address[] memory addressArray) internal pure returns (int256) {
        for (uint256 i=0; i < addressArray.length; i++) {
            if (user == addressArray[i]){
                return int256(i);
            }
        }
        return -1;
    }

}