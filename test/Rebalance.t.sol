// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import {Test, console2} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {RangeProtocolFactory} from "../contracts/RangeProtocolFactory.sol";
import {RangeProtocolVault} from "../contracts/RangeProtocolVault.sol";
import {VaultErrors} from "../contracts/errors/VaultErrors.sol";
import {MockRebalanceTarget} from "../contracts/mock/MockRebalanceTarget.sol";

contract CounterTest is Test {
    uint256 bscFork;
    RangeProtocolFactory factory;
    RangeProtocolVault vault;
    IERC20 token0 = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 token1 = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address WETH9 = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address priceOracle0 = 0xB97Ad0E74fa7d920791E90258A6E2085088b4320;
    address priceOracle1 = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;
    uint24 feeTier = 10000;
    uint256 amount = 400 * 10 ** 18;

    function setUp() public {
        // fork bsc chain
        bscFork = vm.createFork("https://bsc.publicnode.com");
        vm.selectFork(bscFork);

        fundTestContractWithTokens();
        deployFactoryAndVault();
        createPassiveBalanceInVault();
    }

    function test_Revert_Rebalance() external {
        uint256 amount = token0.balanceOf(address(vault)) / 2;
        address target = address(new MockRebalanceTarget(token0, token1));
        bytes memory swapData = abi.encodeWithSignature(
            "swap(uint256)",
            amount
        );
        token1.transfer(target, amount);
        vm.expectRevert(VaultErrors.RebalanceSlippageExceedsThreshold.selector);
        vault.rebalance(target, swapData, true, amount);
    }

    function test_Rebalance() external {
        address target = vm.envAddress("target");
        bytes memory swapData = vm.envBytes("calldata");

        vm.expectRevert(VaultErrors.ZeroRebalanceAmount.selector);
        vault.rebalance(target, swapData, true, 0);
        vm.expectRevert(bytes("Ownable: caller is not the manager"));
        vm.prank(address(vault));
        vault.rebalance(target, swapData, true, amount);

        vault.rebalance(target, swapData, true, amount);

        vm.expectRevert(VaultErrors.RebalanceIntervalNotReached.selector);
        vault.rebalance(target, swapData, true, amount);

        vm.rollFork(block.number - 1);
        vault.rebalance(target, swapData, true, amount);
    }

    function fundTestContractWithTokens() private {
        deal(address(token0), address(this), amount);
        deal(address(token1), address(this), amount);
    }

    function deployFactoryAndVault() private {
        // deploy factory
        factory = new RangeProtocolFactory(0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865);

        // deploy vault implementation
        address vaultImpl = address(new RangeProtocolVault());
        bytes memory initData = abi.encode(
            address(this),
            "Test Token",
            "TT",
            WETH9,
            priceOracle0,
            priceOracle1,
            address(this)
        );

        // create vault proxy
        factory.createVault(
            address(token0),
            address(token1),
            feeTier,
            vaultImpl,
            initData
        );
        vault = RangeProtocolVault(payable(factory.getVaultAddresses(0, 0)[0]));
        vault.updateTicks(-200, 200);
    }

    function createPassiveBalanceInVault() private {
        (uint256 amount0, uint256 amount1, uint256 mintAmount) = vault.getMintAmounts(
            amount,
            amount
        );

        token0.approve(address(vault), amount0);
        token1.approve(address(vault), amount1);

        uint256[2] memory maxAmounts;
        maxAmounts[0] = amount0;
        maxAmounts[1] = amount1;
        vault.mint(mintAmount, false, maxAmounts);

        uint256[2] memory minAmounts;
        vault.removeLiquidity(minAmounts);
    }
}
