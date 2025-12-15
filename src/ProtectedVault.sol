// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ActionGuard.sol";

contract ProtectedVault {
    ActionGuard public guard;

    constructor(address _guard) {
        guard = ActionGuard(_guard);
    }

    function withdraw(uint256 amount) external {
        guard.check(msg.sender, amount);
        guard.recordExecution(msg.sender);

        // token transfer logic would go here
    }

    
}
