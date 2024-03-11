// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IStaderStakePoolManager {
    function deposit(address _receiver) external payable returns (uint256);
}
