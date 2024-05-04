// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Kiln} from "../src/Kiln.sol";

contract KilnScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address yt = vm.envAddress("YT_ADDRESS");
        uint256 roundId = vm.envUint("ROUND_ID");
        address vrf = vm.envAddress("VRF_ADDRESS");
        uint256 lotteryEnd = vm.envUint("LOTTERY_END_TIMESTAMP");
        uint256 mintWindowEnd = vm.envUint("MINT_WINDOW_END_TIMESTAMP");
        uint256 treasuryDivisor = vm.envUint("TREASURY_DIVISOR");
        address treasury = vm.envAddress("TREASURY_ADDRESS");
        uint256 ticketCost = vm.envUint("TICKET_COST");

        vm.startBroadcast(deployerPrivateKey);

        Kiln kiln = new Kiln(yt, roundId, vrf, lotteryEnd, mintWindowEnd, treasuryDivisor, treasury, ticketCost);

        console2.log("====Kiln Address====");
        console2.log(address(kiln));
    }
}
