// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "lib/solmate/src/tokens/ERC721.sol";
import {LibString} from "lib/solmate/src/utils/LibString.sol";

contract Ticket is ERC721 {
    address minter;

    error CallerNotMinter();

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        // msg.sender will be the pottery contract instance
        minter = msg.sender;
    }

    function mint(address to, uint256 tokenId) external onlyMinter {
        _mint(to, tokenId);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return LibString.toString(id);
    }

    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert CallerNotMinter();
        }
        _;
    }
}
