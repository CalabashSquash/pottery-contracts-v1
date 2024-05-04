pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @notice FOR TESTING ONLY.
 */
contract MockYT is ERC20 {
    uint256 public expiry;
    address[] public rewardTokens;
    uint256[] public rewards;
    address public SY;

    constructor(
        uint256 _expiry,
        address[] memory _rewardTokens,
        address _SY,
        uint256 _initialSupply,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        expiry = _expiry;
        rewardTokens = _rewardTokens;
        SY = _SY;
        _mint(msg.sender, _initialSupply);
    }

    function getRewardTokens() external view returns (address[] memory) {
        return rewardTokens;
    }

    /**
     * @dev For tests
     */
    function setRewards(uint256[] memory _rewards) external {
        rewards = _rewards;
    }

    function redeemDueInterestAndRewards(address user, bool, bool)
        external
        returns (uint256 interestOut, uint256[] memory rewardsOut)
    {
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            IERC20(rewardTokens[i]).transfer(user, rewards[i]);
        }
        uint256 zero = 0;
        return (zero, rewards);
    }
}
