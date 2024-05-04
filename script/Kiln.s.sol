// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Kiln} from "../src/Kiln.sol";

contract KilnScript is Script {
    function setUp() public {}

    function run() public {
        address yt = 0xb3c0f96c4208185cC22Afd1b7CF21F1dabd9648A;
        uint256 roundId = 2;
        address vrf = 0x61A023D8e901EB5bEBE75bE94604fDdd2143C3DA;
        uint256 lotteryEnd = 1714872623;
        uint256 mintWindowEnd = 1714870823;
        uint256 treasuryDivisor = 100;
        address treasury = 0xe18aDb62268c655588a2594b5c50Ec5e81af75D3;
        uint256 ticketCost = 5e18;

        vm.startBroadcast();

        Kiln kiln = new Kiln(yt, roundId, vrf, lotteryEnd, mintWindowEnd, treasuryDivisor, treasury, ticketCost);

        console2.log("====Kiln Address====");
        console2.log(address(kiln));
    }
}
