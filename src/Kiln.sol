// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import "openzeppelin/contracts/"
import {IPYieldTokenV2} from "pendle-v2/contracts/interfaces/IPYieldTokenV2.sol";
import {MiniHelpers} from "pendle-v2/contracts/core/libraries/MiniHelpers.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import {console2} from "forge-std/console2.sol";

interface IERC20 {
    function balanceOf(address user) external view returns (uint256);
    function transfer(address to, uint256 amount) external;
}

contract Kiln is ERC721 {
    IPYieldTokenV2 public yt;
    address public vrf;
    mapping(address user => uint256 ytDeposited) public userYtDeposited;
    uint256 public ticketCost;
    uint256 public ticketIdCounter;
    bytes32 public winningNumber;
    uint256 public lotteryEnd;
    uint256 public mintWindowEnd;
    uint256 public treasuryDivisor;
    address public treasury;
    uint256 public ID;

    error NotVRF(address caller);
    error WinningNumberNotSet();
    error LotteryNotOver();
    error LotteryEndsAfterYtExpiration();
    error MintWindowEndsAfterYtExpiration();
    error DepositAfterMintWindow();

    /**
     * @dev Because we mint one NFT per ticket, we can configure the ticket cost based off both the gas price of the
     *      network, and the approximate value of the YT token.
     * @param _ticketCost The price, in yt, of minting a ticket.
     * @param _treasuryDivisor Divide the rewards by this amount to calculate the amount taken by treasury
     */
    constructor(
        address _yt,
        uint256 _roundId,
        address _vrf,
        uint256 _lotteryEnd,
        uint256 _mintWindowEnd,
        uint256 _treasuryDivisor,
        address _treasury,
        uint256 _ticketCost
    ) ERC721(genName(_roundId), genSymbol(_roundId)) {
        yt = IPYieldTokenV2(_yt);
        vrf = _vrf;

        if (lotteryEnd > yt.expiry()) {
            revert LotteryEndsAfterYtExpiration();
        }
        lotteryEnd = _lotteryEnd;

        if (mintWindowEnd > lotteryEnd) {
            revert MintWindowEndsAfterYtExpiration();
        }
        mintWindowEnd = _mintWindowEnd;

        treasuryDivisor = _treasuryDivisor;
        treasury = _treasury;
        ticketCost = _ticketCost;
        ID = _roundId;

        // expiry timing logic
        // DRand, ranDAO
        // NTH: tiers
    }

    function genName(uint256 _roundId) internal pure returns (string memory) {
        string memory roundId = Strings.toString(_roundId);
        return string.concat("Pottery Round ", roundId);
    }

    function genSymbol(uint256 _roundId) internal pure returns (string memory) {
        string memory roundId = Strings.toString(_roundId);
        return string.concat("PR", roundId);
    }

    function depositYT(uint256 buyAmount) external {
        if (block.timestamp > mintWindowEnd) {
            revert DepositAfterMintWindow();
        }
        // Cache storage
        uint256 _ticketIdCounter = ticketIdCounter;

        for (uint256 i = 0; i < buyAmount; i++) {
            _mint(msg.sender, _ticketIdCounter++);
        }

        ticketIdCounter = _ticketIdCounter;
        yt.transferFrom(msg.sender, address(this), buyAmount * ticketCost);
    }

    function vrfCallback(bytes32 randomNumber) public onlyVrf {
        if (!MiniHelpers.isCurrentlyExpired(lotteryEnd)) {
            revert LotteryNotOver();
        }

        winningNumber = randomNumber;
        // TODO payout winner here
    }

    function payOutWinner() public {
        address winner = calculateWinner();
        // get reward token first
        address[] memory rewardTokens = yt.getRewardTokens();
        yt.redeemDueInterestAndRewards(address(this), true, true);
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            uint256 balance = IERC20(rewardTokens[i]).balanceOf(address(this));
            uint256 treasuryReward = balance / treasuryDivisor;
            uint256 winnerReward = balance - treasuryReward;
            IERC20(rewardTokens[i]).transfer(treasury, treasuryReward);
            IERC20(rewardTokens[i]).transfer(winner, winnerReward);
        }

        // TODO also transfer out the SY interest
    }

    function calculateWinner() public view returns (address) {
        if (uint256(winningNumber) == 0) {
            revert WinningNumberNotSet();
        }
        uint256 winningTicket = uint256(winningNumber) % ticketIdCounter;
        return ownerOf(winningTicket);
    }

    function getRewardTokens() public view returns (address[] memory) {
        return yt.getRewardTokens();
    }

    modifier onlyVrf() {
        if (msg.sender != vrf) {
            revert NotVRF(msg.sender);
        }
        _;
    }
}
