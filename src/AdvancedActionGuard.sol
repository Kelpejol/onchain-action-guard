// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AdvancedActionGuard is AccessControl {
    using ECDSA for bytes32;

    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    bytes32 public constant POLICY_ADMIN_ROLE = keccak256("POLICY_ADMIN_ROLE");

    struct Policy {
        uint256 maxAmount;
        uint256 cooldown;
        bool enabled;
    }

    // caller => policyId => policy
    mapping(address => mapping(bytes32 => Policy)) public policies;

    // caller => policyId => last execution timestamp
    mapping(address => mapping(bytes32 => uint256)) public lastExecution;

    // replay protection
    mapping(bytes32 => bool) public usedApprovals;

    error PolicyDisabled();
    error AmountTooHigh();
    error CooldownNotPassed();
    error InvalidSignature();
    error ReplayDetected();

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(POLICY_ADMIN_ROLE, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            POLICY MGMT
    //////////////////////////////////////////////////////////////*/

    function setPolicy(
        address caller,
        bytes32 policyId,
        uint256 maxAmount,
        uint256 cooldown
    ) external onlyRole(POLICY_ADMIN_ROLE) {
        policies[caller][policyId] = Policy({
            maxAmount: maxAmount,
            cooldown: cooldown,
            enabled: true
        });
    }

    function disablePolicy(address caller, bytes32 policyId)
        external
        onlyRole(POLICY_ADMIN_ROLE)
    {
        policies[caller][policyId].enabled = false;
    }

    /*//////////////////////////////////////////////////////////////
                            CHECK LOGIC
    //////////////////////////////////////////////////////////////*/

    function check(
        address caller,
        bytes32 policyId,
        uint256 amount
    ) public view returns (bool) {
        Policy memory policy = policies[caller][policyId];

        if (!policy.enabled) revert PolicyDisabled();
        if (amount > policy.maxAmount) revert AmountTooHigh();
        if (block.timestamp < lastExecution[caller][policyId] + policy.cooldown)
            revert CooldownNotPassed();

        return true;
    }

    function recordExecution(address caller, bytes32 policyId) internal {
        lastExecution[caller][policyId] = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                        SIGNED APPROVAL PATH
    //////////////////////////////////////////////////////////////*/

    function checkWithApproval(
        address caller,
        bytes32 policyId,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(address(this), caller, policyId, amount, nonce)
        ).toEthSignedMessageHash();

        if (usedApprovals[digest]) revert ReplayDetected();
        usedApprovals[digest] = true;

        address signer = digest.recover(signature);
        if (!hasRole(POLICY_ADMIN_ROLE, signer)) revert InvalidSignature();

        check(caller, policyId, amount);
        recordExecution(caller, policyId);


        return true;
        
    }
}
