// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IKiln} from "./IKiln.sol";

contract BlockHashDraw {
    address public s_keeper;
    address public s_owner;

    uint256 public s_lastBlockNumber;

    uint16 immutable s_blockOffset = 10;
    uint16 immutable s_manyBlockInterval = 9;

    mapping(bytes32 => uint256[]) public randomNumbers;

    mapping(bytes32 => address) public kilns;
    mapping(bytes32 => bool) manyBlockDrawn;
    mapping(bytes32 => uint256) public blockNumbers;

    constructor() {
        s_owner = msg.sender;
    }

    function upKeep(address kiln) external onlyKeeper {
        // do nothing
        bytes32 blockHash = blockhash(block.number - 1); // get the previous block hash use as random ID
        uint256 blockNumber = block.number;

        kilns[blockHash] = kiln;
        manyBlockDrawn[blockHash] = false;
        blockNumbers[blockHash] = blockNumber;

    }

    function upKeepMany(address kiln) external onlyKeeper {
        // do nothing
        // get block hash
        bytes32 blockHash = blockhash(block.number - 1); // get the previous block hash use as random ID
        uint256 blockNumber = block.number;

        kilns[blockHash] = kiln;
        manyBlockDrawn[blockHash] = true;
        blockNumbers[blockHash] = blockNumber;
    }

    function draw(bytes32 blockHash) external onlyKeeper {
        uint256 startBlock = blockNumbers[blockHash] + s_manyBlockInterval + s_blockOffset;

        // ensure current blocknumber is at least blockNumbers[blockHash] + s_manyBlockInterval
        require(block.number > startBlock, "BlockHashDraw: min block number not reached");

        IKiln kiln = IKiln(kilns[blockHash]);
        if (manyBlockDrawn[blockHash]) {
            for (uint256 i = 0; i < s_manyBlockInterval; i++) {
                uint256 currentBlock = startBlock - i;
                randomNumbers[blockHash].push(uint256(blockhash(currentBlock)));
            }
            // kiln.vrfCallbackMulti(randomNumbers[blockHash]);
        } else {
            bytes32 randomHash = blockhash(startBlock);
            kiln.vrfCallback(randomHash);
        }
    }

    function setKeeper(address _keeper) external onlyOwner {
        s_keeper = _keeper;
    }

    modifier onlyKeeper() {
        require(msg.sender == s_keeper, "Caller is not the keeper");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner, "Caller is not the owner");
        _;
    }
}
