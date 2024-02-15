//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import {IRangeProtocolVault} from "./interfaces/IRangeProtocolVault.sol";

/**
 * @notice RangeProtocolVaultStorage a storage contract for RangeProtocolVault
 */
abstract contract RangeProtocolVaultStorage is IRangeProtocolVault {
    DataTypes.State internal state;

    function lowerTick() external view override returns (int24) {
        return state.lowerTick;
    }

    function upperTick() external view override returns (int24) {
        return state.upperTick;
    }

    function inThePosition() external view override returns (bool) {
        return state.inThePosition;
    }

    function mintStarted() external view override returns (bool) {
        return state.mintStarted;
    }

    function tickSpacing() external view override returns (int24) {
        return state.tickSpacing;
    }

    function pool() external view override returns (IUniswapV3Pool) {
        return state.pool;
    }

    function token0() external view override returns (IERC20Upgradeable) {
        return state.token0;
    }

    function token1() external view override returns (IERC20Upgradeable) {
        return state.token1;
    }

    function factory() external view override returns (address) {
        return state.factory;
    }

    function managingFee() external view override returns (uint16) {
        return state.managingFee;
    }

    function performanceFee() external view override returns (uint16) {
        return state.performanceFee;
    }

    function managerBalance0() external view override returns (uint256) {
        return state.managerBalance0;
    }

    function managerBalance1() external view override returns (uint256) {
        return state.managerBalance1;
    }

    function userVaults(address user) external view override returns (DataTypes.UserVault memory) {
        return state.userVaults[user];
    }

    function users(uint256 index) external view override returns (address) {
        return state.users[index];
    }

    /**
     * @notice returns array of current user vaults. This function is only intended to be called off-chain.
     * @param fromIdx start index to fetch the user vaults info from.
     * @param toIdx end index to fetch the user vault to.
     */
    function getUserVaults(
        uint256 fromIdx,
        uint256 toIdx
    ) external view override returns (DataTypes.UserVaultInfo[] memory) {
        if (fromIdx == 0 && toIdx == 0) {
            toIdx = state.users.length;
        }
        DataTypes.UserVaultInfo[] memory usersVaultInfo = new DataTypes.UserVaultInfo[](
            toIdx - fromIdx
        );
        uint256 count;
        for (uint256 i = fromIdx; i < toIdx; i++) {
            DataTypes.UserVault memory userVault = state.userVaults[state.users[i]];
            usersVaultInfo[count++] = DataTypes.UserVaultInfo({
                user: state.users[i],
                token0: userVault.token0,
                token1: userVault.token1
            });
        }
        return usersVaultInfo;
    }

    /**
     * @dev returns the length of users array.
     */
    function userCount() external view override returns (uint256) {
        return state.users.length;
    }

    function priceOracle0() external view override returns (address) {
        return state.priceOracle0;
    }

    function priceOracle1() external view override returns (address) {
        return state.priceOracle1;
    }

    function lastRebalanceTimestamp() external view override returns (uint256) {
        return state.lastRebalanceTimestamp;
    }

    /**
     * @dev returns other fee percentage
     */
    function otherFee() external view override returns (uint256) {
        return state.otherFee;
    }

    function otherFeeRecipient() external view override returns (address) {
        return state.otherFeeRecipient;
    }

    function otherBalance0() external view override returns (uint256) {
        return state.otherBalance0;
    }

    function otherBalance1() external view override returns (uint256) {
        return state.otherBalance1;
    }

    function otherFeeClaimer() external view override returns (address) {
        return state.otherFeeClaimer;
    }
}
