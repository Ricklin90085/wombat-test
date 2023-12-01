// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

interface IMasterWombat {
    struct UserInfo {
        uint128 amount;
        uint128 factor;
        uint128 rewardDebt;
        uint128 pendingWom;
    }

    function withdraw(uint256 _pid, uint256 _amount)
        external
        returns (uint256 reward, uint256[] memory additionalRewards);

    function getAssetPid(address asset) external view returns (uint256 pid);

    function userInfo(uint256 pid, address user) external view returns (UserInfo memory);
}
