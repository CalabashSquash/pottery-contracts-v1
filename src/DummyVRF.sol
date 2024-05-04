// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.13;

// import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
// import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
// import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
// import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// import {IKiln} from "./IKiln.sol";

// /**
//  * @title The VRFConsumerV2 contract
//  * @notice A contract that gets random values from Chainlink VRF V2
//  */
// contract VRFDraw is VRFConsumerBaseV2Plus {
//     IVRFCoordinatorV2Plus immutable COORDINATOR;
//     LinkTokenInterface immutable LINKTOKEN;

//     // Your subscription ID.
//     uint256 immutable s_subscriptionId;

//     // The gas lane to use, which specifies the maximum gas price to bump to.
//     // For a list of available gas lanes on each network,
//     // see https://docs.chain.link/docs/vrf-contracts/#configurations
//     bytes32 immutable s_keyHash;

//     // Depends on the number of requested values that you want sent to the
//     // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
//     // so 100,000 is a safe default for this example contract. Test and adjust
//     // this limit based on the network that you select, the size of the request,
//     // and the processing of the callback request in the fulfillRandomWords()
//     // function.
//     uint32 s_callbackGasLimit;

//     // The default is 3, but you can set this higher.
//     uint16 immutable s_requestConfirmations = 1;

//     // For this example, retrieve 2 random values in one request.
//     // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
//     uint32 public s_numWords = 9;

//     uint256[] public s_randomWords;
//     address s_owner;

//     mapping(uint256 => uint256[]) public s_requestIdToRandomWords;
//     mapping(uint256 => address) public s_requestIdToKiln;
//     mapping(uint256 => bool) public s_requestIdToIsMany;
//     uint256 public s_requestId;

//     address public s_keeper;

//     event ReturnedRandomness(uint256[] randomWords);

//     /**
//      * @notice Constructor inherits VRFConsumerBaseV2
//      *
//      * @param subscriptionId - the subscription ID that this contract uses for funding requests
//      * @param vrfCoordinator - coordinator, check https://docs.chain.link/docs/vrf-contracts/#configurations
//      * @param keyHash - the gas lane to use, which specifies the maximum gas price to bump to
//      */
//     constructor(
//         address keeper,
//         uint256 subscriptionId,
//         address vrfCoordinator,
//         address link,
//         bytes32 keyHash,
//         uint32 callbackGasLimit
//     ) VRFConsumerBaseV2Plus(vrfCoordinator) {
//         COORDINATOR = IVRFCoordinatorV2Plus(vrfCoordinator);
//         LINKTOKEN = LinkTokenInterface(link);
//         s_keyHash = keyHash;
//         s_owner = msg.sender;
//         s_callbackGasLimit = callbackGasLimit;
//         s_subscriptionId = subscriptionId;
//         s_keeper = keeper;
//     }

//     function requestRandomWords() external onlyOwner returns (uint256) {
//         uint256 requestId = COORDINATOR.requestRandomWords(
//             VRFV2PlusClient.RandomWordsRequest({
//                 keyHash: s_keyHash,
//                 subId: s_subscriptionId,
//                 requestConfirmations: s_requestConfirmations,
//                 callbackGasLimit: s_callbackGasLimit,
//                 numWords: s_numWords,
//                 extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true})) // new parameter
//             })
//         );

//         // Store the latest requestId for this example.
//         s_requestId = requestId;

//         // Return the requestId to the requester.
//         return requestId;
//     }

//     /**
//      * @notice Callback function used by VRF Coordinator
//      *
//      * @param requestId - id of the request
//      * @param randomWords - array of random results from VRF Coordinator
//      */
//     function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
//         emit FullFill(randomWords);
//     }

//     function setKeeper(address _keeper) external onlyOwner {
//         s_keeper = _keeper;
//     }

//     /**
//      * @notice upKeep function to send VRF number to a kiln, only one number
//      *
//      * @param kiln - the kiln to send the number to
//      */
//     function upKeep(address kiln) external onlyKeeper {
//         // TODO: check market is type of kiln
//         uint256 requestId = _requestRandomWords();

//         s_requestIdToKiln[requestId] = kiln;
//         s_requestIdToIsMany[requestId] = false;
//     }

//     /**
//      * @notice upKeep function to send VRF number to a kiln, multiple numbers
//      *
//      * @param kiln - the kiln to send the numbers to
//      */
//     function upKeepMany(address kiln) external onlyKeeper {
//         // TODO: check market is type of kiln

//         uint256 requestId = _requestRandomWords();

//         s_requestIdToKiln[requestId] = kiln;
//         s_requestIdToIsMany[requestId] = true;
//     }

//     function _requestRandomWords() internal returns (uint256) {
//         uint256 requestId = COORDINATOR.requestRandomWords(
//             VRFV2PlusClient.RandomWordsRequest({
//                 keyHash: s_keyHash,
//                 subId: s_subscriptionId,
//                 requestConfirmations: s_requestConfirmations,
//                 callbackGasLimit: s_callbackGasLimit,
//                 numWords: s_numWords,
//                 extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true})) // new parameter
//             })
//         );

//         // Store the latest requestId for this example.
//         s_requestId = requestId;

//         // Return the requestId to the requester.
//         return requestId;
//     }

//     function setCallbackGasLimit(uint32 _callbackGasLimit) external onlyOwner {
//         s_callbackGasLimit = _callbackGasLimit;
//     }

//     // function setSubscriptionId(uint64 _subscriptionId) external onlyOwner {
//     //     s_subscriptionId = _subscriptionId;
//     // }

//     // function setKeyHash(bytes32 _keyHash) external onlyOwner {
//     //     s_keyHash = _keyHash;
//     // }

//     function setNumWords(uint32 _numWords) external onlyOwner {
//         s_numWords = _numWords;
//     }

//     // modifier onlyOwner() override {
//     //     require(msg.sender == s_owner);
//     //     _;
//     // }

//     modifier onlyKeeper() {
//         require(msg.sender == s_keeper);
//         _;
//     }
// }
