// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {VRFDraw} from "src/VRFDraw.sol";

contract ChainlinkScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        // arbitrum sepolia
        uint256 subscriptionId = 52319185321483977405063119862133968447323266803951283893092420588446176615795;
        address vrfCoordinator = 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61;
        address link = 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E;
        bytes32 keyHash = 0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be;
        uint32 callbackGasLimit = 1000000;
        address keeper = 0xe18aDb62268c655588a2594b5c50Ec5e81af75D3;
        address vrfDraw = address(new VRFDraw(keeper, subscriptionId, vrfCoordinator, link, keyHash, callbackGasLimit));
        vm.stopBroadcast();

        console2.log(vrfDraw);
    }
}
