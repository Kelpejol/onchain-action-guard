// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ActionGuard is AccessControl {
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    uint256 public maxAmount;
    uint256 public cooldown;

    mapping(address => uint256) public lastExecution;

    error AmountTooHigh();
    error CooldownNotPassed();

    constructor(uint256 _maxAmount, uint256 _cooldown) {
        maxAmount = _maxAmount;
        cooldown = _cooldown;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXECUTOR_ROLE, msg.sender);
    }

    function check(address caller, uint256 amount) external view returns (bool) {
        if (!hasRole(EXECUTOR_ROLE, caller)) revert();
        if (amount > maxAmount) revert AmountTooHigh();
        if (block.timestamp < lastExecution[caller] + cooldown) {
            revert CooldownNotPassed();
        }
        return true;
    }

    function recordExecution(address caller) external {
        require(hasRole(EXECUTOR_ROLE, caller));
        lastExecution[caller] = block.timestamp;
    }
}
