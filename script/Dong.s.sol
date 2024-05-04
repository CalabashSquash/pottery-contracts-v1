// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {BlockHashDraw} from "src/BlockHashDraw.sol";
import {Kiln} from "../src/Kiln.sol";
import {MockYT} from "../src/MockYT.sol";
import {MockRewardToken} from "../src/MockRewardToken.sol";

interface coordinator {
    function addConsumer(uint256 subId, address consumer) external;
}

contract ChainlinkScript is Script {
    function setUp() public {}

    function run() public {
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 roundId = vm.envUint("ROUND_ID");
        vm.startBroadcast();

        BlockHashDraw bhDraw = new BlockHashDraw();

        // address[] memory rewardTokens = new address[](1);
        // MockRewardToken rwt = new MockRewardToken(1000 ether, "REWARD TOKEN", "RWT");
        // rewardTokens[0] = address(rwt);
        // uint256[] memory rewardAmounts = new uint256[](1);
        // rewardAmounts[0] = 100 ether;

        {
            // MockYT mockYT =
            //     new MockYT(block.timestamp + (10 * 60), rewardTokens, address(123), 100 ether, "YIELD TOKEN", "YT");
            // // mockYT.setRewards(rewardAmounts);

            // uint256 lotteryEnd = block.timestamp + (20);
            // uint256 mintWindowEnd = block.timestamp + (10);
            // uint256 treasuryDivisor = 10;
            // uint256 ticketCost = 1 ether;
            // address treasury = address(bhDraw);

            // Kiln kiln = new Kiln(
            //     address(mockYT),
            //     roundId,
            //     address(bhDraw),
            //     lotteryEnd,
            //     mintWindowEnd,
            //     treasuryDivisor,
            //     treasury,
            //     ticketCost
            // );

            // uint256 blockNumber = block.number;
            // bhDraw.upKeep(address(kiln));

            vm.stopBroadcast();

            // console2.log("====Kiln Address====");
            // console2.log(address(kiln));

            // console2.log("====YT Address====");
            // console2.log(address(mockYT));

            // console2.log("====RewardTOken Address====");
            // console2.log(address(rewardTokens[0]));

            console2.log("====VRFDraw Address====");
            console2.log(address(bhDraw));
        }
    }
}
