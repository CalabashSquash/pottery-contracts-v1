// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract VRFDraw is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    // Your subscription ID.
    //hardcoded into the constructor
    uint64 s_subscriptionId;
    // Goerli VRF v2 coordinator address
    //address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;
    // The gas lane to use, which specifies the maximum gas price to bump to.
    // Higher gas lane means higher price and lower confirmation times,
    // mainnets on chainlink VRF typically have multiple gas lanes,
    // but Goerli only has one gas lane. For more details,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    //Goerli has a max gas limit of 2.5 million,
    //we'll cap out at 200000, enough for about 10 words
    uint32 callbackGasLimit = 200000;
    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 5;
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    //maximum number of random values is 500 for Goerli Testnet
    uint32 public numWords = 3;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;

    constructor(uint64 subscriptionId, address vrfCoordinator) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }
    // Assumes the subscription is funded sufficiently.

    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId =
            COORDINATOR.requestRandomWords(keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
    }

    function fulfillRandomWords(uint256, /* requestId */ uint256[] memory randomWords) internal override {
        s_randomWords = randomWords;
    }

    //function to change the number of requested words per VRF request.
    function changeNumOfWords(uint32 _numWords) public onlyOwner {
        numWords = _numWords;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}
