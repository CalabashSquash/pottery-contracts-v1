// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

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

    modifier onlyMinter() {
        if (msg.sender != minter) {
            revert CallerNotMinter();
        }
        _;
    }
}
