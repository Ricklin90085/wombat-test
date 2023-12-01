// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IPool} from "../interfaces/wombat/IPool.sol";
import {IMasterWombat} from "../interfaces/wombat/IMasterWombat.sol";
import {IAsset} from "../interfaces/wombat/IAsset.sol";

import "forge-std/console.sol";

contract WombatVault {
    using SafeERC20 for IERC20;
    using SafeERC20 for IAsset;

    uint256 public pid;

    // Tokens used
    IERC20 public asset;
    IERC20 public native;
    IAsset public lp;

    // Third party contracts
    IPool public pool;
    IMasterWombat public masterWombat;

    constructor(
        IERC20 _asset,
        IPool _pool,
        IMasterWombat _masterWombat,
        IAsset _lp,
        IERC20 _native
    ) {
        pool = _pool;
        masterWombat = _masterWombat;
        asset = _asset;
        lp = _lp;
        native = _native;
        console.log(address(lp));
        pid = masterWombat.getAssetPid(address(lp));
        console.log("pid", pid);
    }


    function quoteWithdrawLiquidity(uint256 assets) public view returns (uint256) {
        uint256 max = masterWombat.userInfo(pid, address(this)).amount;
        uint256 xr = pool.exchangeRate(address(asset));
        uint256 assetAmount = assets * 1e12;
        uint256 liquidity = (assetAmount * 1e6) / xr;

        if (liquidity > max) {
            liquidity = max;
        }

        return liquidity;
    }


    function deposit(uint256 amount) public {
        uint256 currentAssets = asset.balanceOf(address(this));
        console.log("current assets", currentAssets);
        console.log("amount", amount);
        if (currentAssets > 0) {
            asset.safeIncreaseAllowance(address(pool), currentAssets);
            pool.deposit(address(asset), amount, 0, address(this), block.timestamp, true);
        }
    }

    function withdraw() public {
        uint256 liquidity = masterWombat.userInfo(pid, address(this)).amount;
        masterWombat.withdraw(pid, liquidity);
        lp.safeIncreaseAllowance(address(pool), liquidity);
        pool.withdraw(address(asset), liquidity, 0, address(this), block.timestamp);
        console.log("asset withdrawed", asset.balanceOf(address(this)));
    }
}
