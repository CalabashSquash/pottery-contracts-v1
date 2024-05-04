// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Kiln} from "../src/Kiln.sol";
import {MockYT} from "../src/MockYT.sol";
import {MockRewardToken} from "../src/MockRewardToken.sol";

contract CounterTest is Test {
    Kiln public kiln;
    MockYT public mockYT;
    address[] public mockRewardTokens;
    MockRewardToken public mockSY;
    uint256 constant bal = 100e18;

    function setUp() public {
        mockRewardTokens.push(address(new MockRewardToken(bal, "1", "1")));
        mockRewardTokens.push(address(new MockRewardToken(bal, "2", "2")));
        mockRewardTokens.push(address(new MockRewardToken(bal, "3", "3")));
        mockSY = new MockRewardToken(bal, "SY", "SY");

        mockYT = new MockYT(block.timestamp + 100, mockRewardTokens, address(mockSY), bal, "YT", "YT");
    }

    function test_KilnHappyPath() public {
        address vrf = address(this);
        uint256 lottoEnd = mockYT.expiry() - 1;
        uint256 mintWindowEnd = mockYT.expiry() - 10;
        uint256 divisor = 10;
        address treasury = address(30);
        uint256 ticketCost = 1e18;
        kiln = new Kiln(address(mockYT), 0, vrf, lottoEnd, mintWindowEnd, divisor, treasury, ticketCost);

        address degen = address(123123);
        mockYT.transfer(degen, 10e18);

        vm.startPrank(degen);
        mockYT.approve(address(kiln), type(uint256).max);
        kiln.depositYT(5); // Buy 5, for 1 SY each (10SY)

        console2.log(kiln.balanceOf(degen));

        uint256 balance = kiln.balanceOf(degen);
        uint256 expectedBalance = 5;

        // assertEq(kiln.balanceOf(degen), 10, "Ticket balance not equal");
        // assertEq(10, 10, "Ticket balance not equal");
        assertEq(balance, expectedBalance);

        vm.warp(lottoEnd + 1);
        vm.expectRevert();
        kiln.depositYT(1);

        kiln.transfer()
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
