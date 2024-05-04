// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Kiln} from "../src/Kiln.sol";
import {MockYT} from "../src/MockYT.sol";
import {MockRewardToken} from "../src/MockRewardToken.sol";

contract KilnScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address[] memory rewardTokens = new address[](1);
        MockRewardToken rwt = new MockRewardToken(1000 ether, "REWARD TOKEN", "RWT");
        rewardTokens[0] = address(rwt);

        uint256[] memory rewardAmounts = new uint256[](1);
        rewardAmounts[0] = 100 ether;

        MockYT mockYT =
            new MockYT(block.timestamp + (10 * 60), rewardTokens, address(123), 1000 ether, "YIELD TOKEN", "YT");
        mockYT.setRewards(rewardAmounts);

        uint256 lotteryEnd = block.timestamp + (2 * (60));
        uint256 mintWindowEnd = block.timestamp + (3 * (60));
        uint256 roundId = 9;
        uint256 treasuryDivisor = 10;
        uint256 ticketCost = 0.5 ether;
        address vrf = 0xAD11fa4db9A36AD458e05F71056ee6279D56FdB4;
        address treasury = vrf;

        Kiln kiln =
            new Kiln(address(mockYT), roundId, vrf, lotteryEnd, mintWindowEnd, treasuryDivisor, treasury, ticketCost);

        mockYT.transfer(0x9332e38f1a9BA964e166DE3eb5c637bc36cD4D27, 5 ether);

        console2.log("====Kiln Address====");
        console2.log(address(kiln));

        console2.log("====YT Address====");
        console2.log(address(mockYT));

        console2.log("====RewardTOken Address====");
        console2.log(address(rewardTokens[0]));
    }
}
