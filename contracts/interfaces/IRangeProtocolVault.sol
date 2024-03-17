//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {IPancakeV3MintCallback} from "../pancake/interfaces/callback/IPancakeV3MintCallback.sol";
import {IPancakeV3SwapCallback} from "../pancake/interfaces/callback/IPancakeV3SwapCallback.sol";
import {IPancakeV3Pool} from "../pancake/interfaces/IPancakeV3Pool.sol";
import {DataTypes} from "../libraries/DataTypes.sol";

interface IRangeProtocolVault is IERC20Upgradeable, IPancakeV3MintCallback, IPancakeV3SwapCallback {
    // EVENTS
    event Minted(
        address indexed receiver,
        uint256 mintAmount,
        uint256 amount0In,
        uint256 amount1In
    );
    event Burned(
        address indexed receiver,
        uint256 burnAmount,
        uint256 amount0Out,
        uint256 amount1Out
    );
    event LiquidityAdded(
        uint256 liquidityMinted,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0In,
        uint256 amount1In
    );
    event LiquidityRemoved(
        uint256 liquidityRemoved,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Out,
        uint256 amount1Out
    );
    event FeesEarned(uint256 feesEarned0, uint256 feesEarned1);
    event FeesUpdated(uint16 managingFee, uint16 performanceFee);
    event InThePositionStatusSet(bool inThePosition);
    event Swapped(bool zeroForOne, int256 amount0, int256 amount1);
    event TicksSet(int24 lowerTick, int24 upperTick);
    event MintStarted();
    event SwapRouterAddedToWhitelist(address swapRouter);
    event SwapRouterRemovedFromWhitelist(address swapRouter);
    event RebalancePausedStatusChanged(bool pauseStatus);

    // GETTER FUNCTIONS
    function lowerTick() external view returns (int24);

    function upperTick() external view returns (int24);

    function inThePosition() external view returns (bool);

    function mintStarted() external view returns (bool);

    function tickSpacing() external view returns (int24);

    function pool() external view returns (IPancakeV3Pool);

    function token0() external view returns (IERC20Upgradeable);

    function token1() external view returns (IERC20Upgradeable);

    function factory() external view returns (address);

    function managingFee() external view returns (uint16);

    function performanceFee() external view returns (uint16);

    function managerBalance0() external view returns (uint256);

    function managerBalance1() external view returns (uint256);

    function userVaults(address user) external view returns (DataTypes.UserVault memory);

    function users(uint256 index) external view returns (address);

    function WETH9() external view returns (address);

    function getUserVaults(
        uint256 fromIdx,
        uint256 toIdx
    ) external view returns (DataTypes.UserVaultInfo[] memory);

    function getMintAmounts(
        uint256 amount0Max,
        uint256 amount1Max
    ) external view returns (uint256 amount0, uint256 amount1, uint256 mintAmount);

    function getUnderlyingBalances()
        external
        view
        returns (uint256 amount0Current, uint256 amount1Current);

    function getCurrentFees() external view returns (uint256 fee0, uint256 fee1);

    function getPositionID() external view returns (bytes32 positionID);

    function userCount() external view returns (uint256);

    function rebalancePaused() external view returns (bool);

    function lastRebalanceTimestamp() external view returns (uint256);

    function minimumRebalanceInterval() external view returns (uint256);

    function whitelistedSwapRouters(address swapRouter) external view returns (bool);

    function swapRouters(uint256 idx) external view returns (address);

    // STATE MODIFYING FUNCTIONS
    function initialize(address _pool, int24 _tickSpacing, bytes memory data) external;

    function updateTicks(int24 _lowerTick, int24 _upperTick) external;

    function mint(
        uint256 mintAmount,
        bool depositNative,
        uint256[2] calldata maxAmountsIn
    ) external payable returns (uint256 amount0, uint256 amount1);

    function burn(
        uint256 burnAmount,
        bool withdrawNative,
        uint256[2] calldata minAmountsOut
    ) external returns (uint256 amount0, uint256 amount1);

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function removeLiquidity(uint256[2] calldata minAmountsOut) external;

    function swap(
        bool zeroForOne,
        int256 swapAmount,
        uint160 sqrtPriceLimitX96,
        uint256 minAmountOut
    ) external returns (int256 amount0, int256 amount1);

    function addLiquidity(
        int24 newLowerTick,
        int24 newUpperTick,
        uint256 amount0,
        uint256 amount1,
        uint256[2] calldata minAmountsIn,
        uint256[2] calldata maxAmountsIn
    ) external returns (uint256 remainingAmount0, uint256 remainingAmount1);

    function rebalance(
        address target,
        bytes calldata swapData,
        bool zeroForOne,
        uint256 amount
    ) external;

    function mintETHx(uint256 amount) external returns (uint256 mintedETHx);

    function pullFeeFromPool() external;

    function collectManager() external;

    function updateFees(uint16 newManagingFee, uint16 newPerformanceFee) external;

    function whiteListSwapRouter(address swapRouter) external;

    function removeSwapRouterFromWhitelist(address swapRouter) external;

    function setMinimumRebalanceInterval(uint256 _minimumRebalanceInterval) external;
}
