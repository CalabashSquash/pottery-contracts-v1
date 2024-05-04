// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {VRFDraw} from "src/VRFDraw.sol";
import {Kiln} from "../src/Kiln.sol";
import {MockYT} from "../src/MockYT.sol";
import {MockRewardToken} from "../src/MockRewardToken.sol";

interface coordinator {
    function addConsumer(uint256 subId, address consumer) external;
}

contract ChainlinkScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 roundId = vm.envUint("ROUND_ID");
        address vrfDraw;
        {
            // arbitrum sepolia
            uint256 subscriptionId = 52319185321483977405063119862133968447323266803951283893092420588446176615795;
            address vrfCoordinator = 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61;
            address link = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
            bytes32 keyHash = 0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be;
            uint32 callbackGasLimit = 500000;
            address keeper = 0xe18aDb62268c655588a2594b5c50Ec5e81af75D3;

            vm.startBroadcast(deployerPrivateKey);

            vrfDraw = address(new VRFDraw(keeper, subscriptionId, vrfCoordinator, link, keyHash, callbackGasLimit));
            coordinator(vrfCoordinator).addConsumer(subscriptionId, vrfDraw);
        }

        address[] memory rewardTokens = new address[](1);
        MockRewardToken rwt = new MockRewardToken(1000 ether, "REWARD TOKEN", "RWT");
        rewardTokens[0] = address(rwt);
        uint256[] memory rewardAmounts = new uint256[](1);
        rewardAmounts[0] = 100 ether;

        {
            MockYT mockYT =
                new MockYT(block.timestamp + (10 * 60), rewardTokens, address(123), 100 ether, "YIELD TOKEN", "YT");
            mockYT.setRewards(rewardAmounts);

            uint256 lotteryEnd = block.timestamp + (20);
            uint256 mintWindowEnd = block.timestamp + (10);
            uint256 treasuryDivisor = 10;
            uint256 ticketCost = 1 ether;
            address treasury = vrfDraw;

            Kiln kiln = new Kiln(
                address(mockYT), roundId, vrfDraw, lotteryEnd, mintWindowEnd, treasuryDivisor, treasury, ticketCost
            );

            VRFDraw(vrfDraw).upKeep(address(kiln));

            vm.stopBroadcast();

            console2.log("====Kiln Address====");
            console2.log(address(kiln));

            console2.log("====YT Address====");
            console2.log(address(mockYT));

            console2.log("====RewardTOken Address====");
            console2.log(address(rewardTokens[0]));

            console2.log("====VRFDraw Address====");
            console2.log(vrfDraw);
        }
    }
}
