// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Kiln} from "../src/Kiln.sol";
import {MockYT} from "../src/MockYT.sol";
import {MockRewardToken} from "../src/MockRewardToken.sol";

interface IERC20 {
    function balanceOf(address user) external view returns (uint256);
    function transfer(address to, uint256 amount) external;
}

contract CounterTest is Test {
    Kiln public kiln;
    MockYT public mockYT;
    address[] public mockRewardTokens;
    MockRewardToken public mockSY;
    uint256 constant bal = 100e18;

    uint256 constant rewardAmount = 5e18; // 5
    uint256 constant treasuryReward = 5e17; // 0.5
    uint256[] rewards;

    error DepositAfterMintWindow();
    error WinnerAlreadyPaid();

    function setUp() public {
        mockRewardTokens.push(address(new MockRewardToken(bal, "1", "1")));
        mockRewardTokens.push(address(new MockRewardToken(bal, "2", "2")));
        mockRewardTokens.push(address(new MockRewardToken(bal, "3", "3")));
        mockSY = new MockRewardToken(bal, "SY", "SY");

        mockYT = new MockYT(block.timestamp + 100, mockRewardTokens, address(mockSY), bal, "YT", "YT");
        rewards.push(rewardAmount);
        rewards.push(rewardAmount);
        rewards.push(rewardAmount);
        mockYT.setRewards(rewards);

        IERC20(mockRewardTokens[0]).transfer(address(mockYT), rewardAmount);
        IERC20(mockRewardTokens[1]).transfer(address(mockYT), rewardAmount);
        IERC20(mockRewardTokens[2]).transfer(address(mockYT), rewardAmount);
    }

    function test_KilnHappyPath() public {
        address vrf = address(this);
        uint256 lottoEnd = mockYT.expiry() - 1;
        uint256 mintWindowEnd = mockYT.expiry() - 10;
        uint256 divisor = 10;
        address treasury = address(30);
        uint256 ticketCost = 1e18;
        kiln = new Kiln(address(mockYT), 0, vrf, lottoEnd, mintWindowEnd, divisor, treasury, ticketCost);

        address degen = address(0x123123);
        mockYT.transfer(degen, 10e18);

        vm.startPrank(degen);
        mockYT.approve(address(kiln), type(uint256).max);
        kiln.depositYT(5); // Buy 5, for 1 YT each (5YT)

        console2.log(kiln.balanceOf(degen));

        uint256 balance = kiln.balanceOf(degen);
        uint256 expectedBalance = 5;

        // assertEq(kiln.balanceOf(degen), 10, "Ticket balance not equal");
        // assertEq(10, 10, "Ticket balance not equal");
        assertEq(balance, expectedBalance);

        vm.warp(mintWindowEnd + 1);

        vm.expectRevert(DepositAfterMintWindow.selector);
        kiln.depositYT(1);

        address secondPlayer = address(0x9999);

        kiln.transferFrom(degen, secondPlayer, 2);

        vm.stopPrank();
        vm.warp(lottoEnd + 1);

        {
            // hashes to 2 modulo total supply (secondPlayer owns tokenId 2)
            uint256 number = 126;
            bytes32 winningHash = keccak256(abi.encodePacked(number));
            uint256 preBal1 = IERC20(mockRewardTokens[0]).balanceOf(secondPlayer);
            uint256 preBal2 = IERC20(mockRewardTokens[1]).balanceOf(secondPlayer);
            uint256 preBal3 = IERC20(mockRewardTokens[2]).balanceOf(secondPlayer);

            kiln.vrfCallback(winningHash);

            uint256 postBal1 = IERC20(mockRewardTokens[0]).balanceOf(secondPlayer);
            uint256 postBal2 = IERC20(mockRewardTokens[1]).balanceOf(secondPlayer);
            uint256 postBal3 = IERC20(mockRewardTokens[2]).balanceOf(secondPlayer);

            assertEq(preBal1 + rewardAmount - treasuryReward, postBal1, "1");
            assertEq(preBal2 + rewardAmount - treasuryReward, postBal2, "2");
            assertEq(preBal3 + rewardAmount - treasuryReward, postBal3, "3");

            vm.expectRevert(WinnerAlreadyPaid.selector);
            kiln.payOutWinner();
        }

        uint256 postBal1T = IERC20(mockRewardTokens[0]).balanceOf(treasury);
        uint256 postBal2T = IERC20(mockRewardTokens[1]).balanceOf(treasury);
        uint256 postBal3T = IERC20(mockRewardTokens[2]).balanceOf(treasury);

        assertEq(treasuryReward, postBal1T);
        assertEq(treasuryReward, postBal2T);
        assertEq(treasuryReward, postBal3T);
    }
}

//     function test_Increment() public {
//         counter.increment();
//         assertEq(counter.number(), 1);
//     }

//     function testFuzz_SetNumber(uint256 x) public {
//         counter.setNumber(x);
//         assertEq(counter.number(), x);
//     }
// }
