# Security Model

This contract acts as a policy enforcement layer.
It does NOT execute actions or hold funds.

## Trust Assumptions

- POLICY_ADMIN_ROLE is trusted to define valid policies
- Off-chain approvals are trusted only when signed
  by a POLICY_ADMIN_ROLE holder
- Callers may be adversarial

## Threat Model

### 1. Replay Attacks
Mitigation:
- Each signed approval is hashed and stored
- Replays are explicitly rejected

### 2. Privilege Escalation
Mitigation:
- Role-based access control via OpenZeppelin
- No dynamic role assignment in execution paths

### 3. Bypass of Policy Checks
Mitigation:
- Policy enforcement separated from execution
- Guard must be explicitly called by protected contracts

### 4. Denial of Service
Notes:
- Cooldown enforcement is per-caller, per-policy
- No global locks or shared execution counters

## Non-Goals

- Byzantine fault tolerance
- Full governance decentralization
- Economic incentive design
