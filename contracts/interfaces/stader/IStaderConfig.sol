// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IStaderConfig {
    function getStakePoolManager() external view returns (address);
}
