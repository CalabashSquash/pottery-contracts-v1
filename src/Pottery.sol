// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "openzeppelin/contracts/"
import {IPYieldTokenV2} from "pendle-v2/contracts/interfaces/IPYieldTokenV2.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ticket} from "./Ticket.sol";

contract Kiln {
    IPYieldTokenV2 public yt;
    Ticket public ticket;
    address public vrf;
    mapping(address user => uint256 ytDeposited) public userYtDeposited;
    uint256 public ticketCost;
    uint256 public ticketIdCounter;
    bytes32 public winningNumber;

    error NotVRF(address caller);
    error WinningNumberNotSet();

    constructor(address _yt, uint256 _roundId, address _vrf) {
        yt = IPYieldTokenV2(_yt);
        string memory roundId = Strings.toString(_roundId);
        ticket = new Ticket(string.concat("Pottery Round ", roundId), string.concat("PR", roundId));
        vrf = _vrf;
    }

    function depositYT(uint256 buyAmount) public {
        // Cache storage
        _ticketIdCounter = ticketIdCounter;

        for (uint256 i = 0; i < buyAmount; i++) {
            ticket.mint(msg.sender, _ticketIdCounter++);
        }

        ticketIdCounter = _ticketIdCounter;
        yt.transferFrom(msg.sender, address(this), buyAmount * ticketCost / 10e18);
    }

    function vrfCallback(bytes32 randomNumber) public onlyVrf {
        winningNumber = randomNumber;
    }

    function calculateWinner() public view {
        if (winningNumber == 0) {
            revert WinningNumberNotSet();
        }
        uint256 winningTicket = winningNumber % ticketIdCounter;
        address winner = ticket.ownerOf(winningTicket);
    }

    modifier onlyVrf() {
        if (msg.sender != vrf) {
            revert NotVRF(caller);
        }
    }
}
