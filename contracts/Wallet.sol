// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Wallet {
    struct UserBalance {
        address user;
        uint256 balance;
        uint256 reflective;
        bool isExcluded;
    }

    mapping(address => UserBalance) userBalances;

    constructor() {}

    function getUserBalances(address _address) public view returns (uint256) {
        UserBalance storage _userBalance = userBalances[_address];
        if (_userBalance.isExcluded) return _userBalance.balance;
        return _userBalance.reflective;
    }
}
