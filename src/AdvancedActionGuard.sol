// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
 
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title AdvancedActionGuard
 * @notice Multi-policy guard with signed approval support
 * @dev Supports per-caller, per-policy enforcement with off-chain signatures
 */
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

    event PolicySet(address indexed caller, bytes32 indexed policyId, uint256 maxAmount, uint256 cooldown);
    event PolicyDisabled(address indexed caller, bytes32 indexed policyId);
    event ExecutionRecorded(address indexed caller, bytes32 indexed policyId, uint256 timestamp);
    event ApprovalUsed(bytes32 indexed digest);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(POLICY_ADMIN_ROLE, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            POLICY MGMT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Set or update a policy for a caller
     * @param caller Address the policy applies to
     * @param policyId Unique identifier for the policy
     * @param maxAmount Maximum amount allowed
     * @param cooldown Minimum time between executions
     */
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
        emit PolicySet(caller, policyId, maxAmount, cooldown);
    }

    /**
     * @notice Disable a policy
     * @param caller Address the policy applies to
     * @param policyId Policy to disable
     */
    function disablePolicy(address caller, bytes32 policyId)
        external
        onlyRole(POLICY_ADMIN_ROLE)
    {
        policies[caller][policyId].enabled = false;
        emit PolicyDisabled(caller, policyId);
    }

    /*//////////////////////////////////////////////////////////////
                            CHECK LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Check if an action is allowed under a specific policy
     * @param caller Address attempting the action
     * @param policyId Policy to check against
     * @param amount Amount of the action
     * @return bool True if allowed
     */
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

    /**
     * @notice Record an execution to enforce cooldown
     * @param caller Address that executed
     * @param policyId Policy that was used
     */
    function recordExecution(address caller, bytes32 policyId) internal {
        lastExecution[caller][policyId] = block.timestamp;
        emit ExecutionRecorded(caller, policyId, block.timestamp);
    }

    /*//////////////////////////////////////////////////////////////
                        SIGNED APPROVAL PATH
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Check action with off-chain signed approval
     * @param caller Address attempting the action
     * @param policyId Policy to check
     * @param amount Amount of the action
     * @param nonce Unique nonce for replay protection
     * @param signature Signature from POLICY_ADMIN_ROLE holder
     * @return bool True if allowed
     */
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

        emit ApprovalUsed(digest);

        return true;
    }
}
