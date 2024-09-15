//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        // console.log(
        //     "recent fundMe owner %s",
        //     "msg sender %s",
        //     FundMe(mostRecentlyDeployed).getOwner(),
        //     msg.sender
        // );
        // console.log("msg sender funds %s", msg.sender.balance);
        vm.startBroadcast();
        FundMe(mostRecentlyDeployed).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        // console.log(
        //     "recent fundMe owner %s",
        //     FundMe(mostRecentlyDeployed).getOwner()
        // );
        // console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(mostRecentlyDeployed).withdraw();
        console.log(
            "withdrawal owner %s",
            FundMe(mostRecentlyDeployed).getOwner()
        );
        vm.stopBroadcast();
        console.log("Withdrawn FundMe");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFundMe(mostRecentlyDeployed);
    }
}
