// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {VRFDraw} from "src/VRFDraw.sol";

contract ChainlinkScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // arbitrum sepolia
        uint256 subscriptionId = 30267214356765260478491562931478314358894768148389424553055604642560192273695;
        address vrfCoordinator = 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61;
        address link = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
        bytes32 keyHash = 0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be;
        uint32 callbackGasLimit = 200000;
        new VRFDraw(subscriptionId, vrfCoordinator, link, keyHash, callbackGasLimit);
        vm.stopBroadcast();
    }
}
