// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

/// @title ExchangeRate
/// @notice This struct holds data related to the exchange rate between ETH and ETHX.
struct ExchangeRate {
    /// @notice The block number when the exchange rate was last updated.
    uint256 reportingBlockNumber;
    /// @notice The total balance of Ether (ETH) in the system.
    uint256 totalETHBalance;
    /// @notice The total supply of the liquid staking token (ETHX) in the system.
    uint256 totalETHXSupply;
}

interface IStaderOracle {
    function getExchangeRate() external view returns (ExchangeRate memory);
}
