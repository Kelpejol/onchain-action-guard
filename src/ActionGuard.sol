// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ActionGuard
 * @notice Simple on-chain guard that enforces policy constraints before execution
 * @dev Implements cooldown periods and amount limits with role-based access control
 */
contract ActionGuard is AccessControl {
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    uint256 public maxAmount;
    uint256 public cooldown;

    mapping(address => uint256) public lastExecution;

    error AmountTooHigh();
    error CooldownNotPassed();
    error NotAuthorized();

    event PolicyUpdated(uint256 maxAmount, uint256 cooldown);
    event ExecutionRecorded(address indexed caller, uint256 timestamp);

    /**
     * @notice Initialize the guard with policy parameters
     * @param _maxAmount Maximum amount allowed per execution
     * @param _cooldown Minimum time between executions (in seconds)
     */
    constructor(uint256 _maxAmount, uint256 _cooldown) {
        maxAmount = _maxAmount;
        cooldown = _cooldown;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXECUTOR_ROLE, msg.sender);
    }

    /**
     * @notice Check if an action is allowed under current policy
     * @param caller Address attempting the action
     * @param amount Amount of the action
     * @return bool True if action is allowed
     */
    function check(address caller, uint256 amount) external view returns (bool) {
        if (!hasRole(EXECUTOR_ROLE, caller)) revert NotAuthorized();
        if (amount > maxAmount) revert AmountTooHigh();
        if (block.timestamp < lastExecution[caller] + cooldown) {
            revert CooldownNotPassed();
        }
        return true;
    }

    /**
     * @notice Record an execution to enforce cooldown
     * @param caller Address that executed the action
     */
    function recordExecution(address caller) external {
        require(hasRole(EXECUTOR_ROLE, caller), "Not authorized");
        lastExecution[caller] = block.timestamp;
        emit ExecutionRecorded(caller, block.timestamp);
    }

    /**
     * @notice Update policy parameters (admin only)
     * @param _maxAmount New maximum amount
     * @param _cooldown New cooldown period
     */
    function updatePolicy(uint256 _maxAmount, uint256 _cooldown) 
        external 
        onlyRole(DEFAULT_ADMIN_ROLE) 
    {
        maxAmount = _maxAmount;
        cooldown = _cooldown;
        emit PolicyUpdated(_maxAmount, _cooldown);
    }
}
