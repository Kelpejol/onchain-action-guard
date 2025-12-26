// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ActionGuard.sol";

/**
 * @title ProtectedVault
 * @notice Example contract showing ActionGuard integration
 * @dev Demonstrates how to use the guard for withdrawal protection
 */
contract ProtectedVault {
    ActionGuard public guard;

    event Withdrawal(address indexed caller, uint256 amount);

    /**
     * @notice Initialize vault with guard
     * @param _guard Address of the ActionGuard contract
     */
    constructor(address _guard) {
        guard = ActionGuard(_guard);
    }

    /**
     * @notice Withdraw with guard protection
     * @param amount Amount to withdraw
     */
    function withdraw(uint256 amount) external {
        // Check policy
        guard.check(msg.sender, amount);
        
        // Record execution
        guard.recordExecution(msg.sender);

        // Perform withdrawal (simplified example)
        emit Withdrawal(msg.sender, amount);
        
        // In real implementation:
        // - Transfer tokens
        // - Update balances
        // - Handle failures
    }
}
