// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/Test.sol";

import {IPool} from "../../src/interfaces/wombat/IPool.sol";
import {IMasterWombat} from "../../src/interfaces/wombat/IMasterWombat.sol";
import {IAsset} from "../../src/interfaces/wombat/IAsset.sol";

contract WombatVaultTest is Test {
    address alice = address(1);

    IERC20 USDC = IERC20(vm.envAddress("BSC_USDC"));
    IAsset USDCLP = IAsset(vm.envAddress("BSC_WOMBAT_USDC_LP"));

    IPool pool = IPool(vm.envAddress("BSC_WOMBAT_POOL"));
    IMasterWombat masterWombat = IMasterWombat(vm.envAddress("BSC_WOMBAT_MASTERWOMBAT"));

    uint256 pid;
    

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("bsc"), 33912589);
        pid = masterWombat.getAssetPid(address(USDCLP));
        console.log(pid);
    }


    function testWithdraw() public {
        uint256 amount = 10 * 1e6;
        deal(address(USDC), address(this), amount);
        USDC.approve(address(pool), type(uint256).max);
        USDCLP.approve(address(pool),  type(uint256).max);
        uint256 i = 1;
        while (i < 10000) {
            pool.deposit(address(USDC), USDC.balanceOf(address(this)), 0, address(this), block.timestamp, true);

            uint256 liquidity = masterWombat.userInfo(pid, address(this)).amount;
            masterWombat.withdraw(pid, liquidity);
            pool.withdraw(address(USDC), liquidity, 0, address(this), block.timestamp);
            console.log("USDC withdrawed", USDC.balanceOf(address(this)));
            i++;
        }
        console.log('ORIG', amount);
        console.log('USDC', USDC.balanceOf(address(this)));

        console.log(i);
    }
}
