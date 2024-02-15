//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockRebalanceTarget {
    IERC20 token0;
    IERC20 token1;

    constructor(IERC20 _token0, IERC20 _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function swap(uint256 amount) external {
        token0.transferFrom(msg.sender, address(this), amount);
        token1.transfer(msg.sender, amount / 2);
    }
}
