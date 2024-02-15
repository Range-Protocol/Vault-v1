//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IRangeProtocolFactory {
    event VaultCreated(address indexed pool, address indexed vault);
    event VaultImplUpgraded(address indexed vault, address indexed implementation);
    event DeployerSet(address deployer);

    function createVault(
        address tokenA,
        address tokenB,
        uint24 fee,
        address implementation,
        bytes memory configData
    ) external;

    function upgradeVaults(address[] calldata _vaults, address[] calldata _impls) external;

    function upgradeVault(address _vault, address _impl) external;
}
