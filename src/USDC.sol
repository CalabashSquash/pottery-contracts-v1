pragma solidity ^0.8.13;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

contract USDC is ERC20 {
    constructor(uint256 _initialSupply, string memory _name, string memory _symbol) ERC20(_name, _symbol, 18) {
        _mint(msg.sender, _initialSupply);
    }
}
