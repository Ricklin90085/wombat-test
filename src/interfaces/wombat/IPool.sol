// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

interface IPool {
    function deposit(
        address token,
        uint256 amount,
        uint256 minimumLiquidity,
        address to,
        uint256 deadline,
        bool shouldStake
    ) external returns (uint256 liquidity);

    function withdraw(address token, uint256 liquidity, uint256 minimumAmount, address to, uint256 deadline)
        external
        returns (uint256 amount);

    function quotePotentialWithdraw(address token, uint256 liquidity) external view returns (uint256 amount);

    function exchangeRate(address token) external view returns (uint256 xr);
}
