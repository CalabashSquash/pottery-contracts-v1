// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "openzeppelin/contracts/"
import {IPYieldTokenV2} from "pendle-v2/contracts/interfaces/IPYieldTokenV2.sol";
import {MiniHelpers} from "pendle-v2/contracts/libraries/MiniHelpers.sol";
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

    uint256 public lotteryEnd;
    uint256 public mintWindowEnd;

    error NotVRF(address caller);
    error WinningNumberNotSet();
    error LotteryNotOver();
    error LotteryEndsAfterYtExpiration();
    error DepositAfterMintWindow();

    constructor(address _yt, uint256 _roundId, address _vrf, uint256 _lotteryEnd, uint256 _mintWindowEnd) {
        yt = IPYieldTokenV2(_yt);
        string memory roundId = Strings.toString(_roundId);
        ticket = new Ticket(string.concat("Pottery Round ", roundId), string.concat("PR", roundId));
        vrf = _vrf;

        if (lotteryEnd > yt.expiry()) {
            revert LotteryEndsAfterYtExpiration();
        }
        lotteryEnd = _lotteryEnd;

        if (mintWindowEnd > lotteryEnd) {
            revert LotteryEndsAfterYtExpiration();
        }
        mintWindowEnd _mintWindowEnd;

        // expiry timing logic
        // DRand, ranDAO
    }

    function depositYT(uint256 buyAmount) external {
        if (block.timestamp > mintWindowEnd) {
            revert DepositAfterMintWindow();
        }
        // Cache storage
        _ticketIdCounter = ticketIdCounter;

        for (uint256 i = 0; i < buyAmount; i++) {
            ticket.mint(msg.sender, _ticketIdCounter++);
        }

        ticketIdCounter = _ticketIdCounter;
        yt.transferFrom(msg.sender, address(this), buyAmount * ticketCost / 10e18);
    }

    function vrfCallback(bytes32 randomNumber) public onlyVrf {
        if (!MiniHelpers.isCurrentlyExpired(lotteryEnd)) {
            revert LotteryNotOver();
        }

        winningNumber = randomNumber;
    }

    function payOutWinner() external {
        address winner = calculateWinner();
        // get reward token first
        yt.
    }

    function calculateWinner() public view returns (address) {
        if (winningNumber == 0) {
            revert WinningNumberNotSet();
        }
        uint256 winningTicket = winningNumber % ticketIdCounter;
        return ticket.ownerOf(winningTicket);
    }

    modifier onlyVrf() {
        if (msg.sender != vrf) {
            revert NotVRF(caller);
        }
    }
}
