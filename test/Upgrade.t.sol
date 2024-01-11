// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import {Test, console2} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {RangeProtocolVault} from "../contracts/RangeProtocolVault.sol";
import {VaultErrors} from "../contracts/errors/VaultErrors.sol";


contract Rebalance is Test {
    uint256 fork;
    address timelock = 0x9eD6C646b4A57e48DFE7AE04FBA4c857AD71d162;
    RangeProtocolVault vault = RangeProtocolVault(payable(0x5db61A5f05580Cf620a9d0f9266E7432811DC309));

    function setUp() public {
        // fork main chain
        fork = vm.createFork("https://bsc-dataseed.bnbchain.org");
        vm.selectFork(fork);
    }

    function testUpgrade() external {
        RangeProtocolVault impl = new RangeProtocolVault();
        vm.prank(0xad2b34a2245b5a7378964BC820e8F34D14adF312);
        address(vault).call(abi.encodeWithSignature("upgradeTo(address)", address(impl)));

        console2.log(vault.priceOracle0());
        console2.log(vault.priceOracle1());
        console2.log(vault.otherFee());
        console2.log(vault.otherFeeRecipient());
        bytes memory data = abi.encode(
            address(0x1),
            address(0x2),
            3000,
            address(0x3)
        );
//        vm.expectRevert(VaultErrors.CannotUpgrade.selector);
//        vault.upgradeStorage(data);

        vm.prank(timelock);
        vault.upgradeStorage(data);
        console2.log(vault.priceOracle0());
        console2.log(vault.priceOracle1());
        console2.log(vault.otherFee());
        console2.log(vault.otherFeeRecipient());
    }
}
