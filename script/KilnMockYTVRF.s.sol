// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Script, console2} from "forge-std/Script.sol";
// import {Kiln} from "../src/Kiln.sol";
// import {MockYT} from "../src/MockYT.sol";
// import {MockRewardToken} from "../src/MockRewardToken.sol";
// import {VRFDraw} from "../src/VRFDraw.sol";

// contract KilnScript is Script {
//     function setUp() public {}

//     function run() public {
//         uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
//         uint256 roundId = vm.envUint("ROUND_ID");
//         uint256 subscriptionId = vm.envUint("SUBSCRIPTION_ID");
//         address vrfCoordinator = vm.envAddress("VRF_COORDINATOR");
//         address link = vm.envAddress("LINK");
//         bytes32 keyHash = vm.envBytes32("KEY_HASH");
//         uint32 callbackGasLimit = 500000;

//         vm.startBroadcast(deployerPrivateKey);

//         address[] memory rewardTokens = new address[](1);
//         MockRewardToken rwt = new MockRewardToken(1000 ether, "REWARD TOKEN", "RWT");
//         rewardTokens[0] = address(rwt);

//         uint256[] memory rewardAmounts = new uint256[](1);
//         rewardAmounts[0] = 100 ether;

//         MockYT mockYT =
//             new MockYT(block.timestamp + (10 * 60), rewardTokens, address(123), 100 ether, "YIELD TOKEN", "YT");
//         mockYT.setRewards(rewardAmounts);

//         /* DEPLOY VRFDRAW */
//         address vrfDraw = new VRFDraw(subscriptionId, vrfCoordinator, link, keyHash, callbackGasLimit);

//         /* DEPLOY KILN */
//         uint256 lotteryEnd = block.timestamp + (8 * 60);
//         uint256 mintWindowEnd = block.timestamp + (7 * 60);
//         uint256 treasuryDivisor = 10;
//         uint256 ticketCost = 1 ether;
//         address treasury = 0xe18aDb62268c655588a2594b5c50Ec5e81af75D3;

//         Kiln kiln =
//             new Kiln(address(mockYT), roundId, vrf, lotteryEnd, mintWindowEnd, treasuryDivisor, treasury, ticketCost);

//         console2.log("====Kiln Address====");
//         console2.log(address(kiln));

//         console2.log("====YT Address====");
//         console2.log(address(mockYT));

//         console2.log("====RewardTOken Address====");
//         console2.log(address(rewardTokens[0]));
//     }
// }
