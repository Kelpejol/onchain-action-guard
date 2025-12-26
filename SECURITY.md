# Security Model

This contract acts as a policy enforcement layer. It does NOT execute actions or hold funds.

## Trust Assumptions

- `DEFAULT_ADMIN_ROLE` is trusted to manage roles
- `POLICY_ADMIN_ROLE` is trusted to define valid policies
- Off-chain approvals are trusted only when signed by a POLICY_ADMIN_ROLE holder
- Callers may be adversarial

## Threat Model

### 1. Replay Attacks
**Mitigation:**
- Each signed approval is hashed and stored in `usedApprovals`
- Replays are explicitly rejected
- Nonce-based system prevents signature reuse

### 2. Privilege Escalation
**Mitigation:**
- Role-based access control via OpenZeppelin
- No dynamic role assignment in execution paths
- Explicit role checks on all sensitive operations

### 3. Bypass of Policy Checks
**Mitigation:**
- Policy enforcement separated from execution
- Guard must be explicitly called by protected contracts
- No way to bypass the check-and-record pattern

### 4. Denial of Service
**Notes:**
- Cooldown enforcement is per-caller, per-policy
- No global locks or shared execution counters
- DoS on individual caller doesn't affect others

### 5. Front-Running
**Considerations:**
- Signed approvals can be front-run
- Use private mempools or commit-reveal if needed
- Not protected at protocol level

## Known Limitations

- **No Economic Security**: Flash loans can be used to manipulate if not carefully integrated
- **Relies on Protected Contract**: Contract using the guard must actually call it
- **Admin Key Risk**: Admin key compromise allows policy manipulation
- **No Reentrancy Protection**: Calling contracts must handle reentrancy

## Non-Goals

- Byzantine fault tolerance
- Full governance decentralization
- Economic incentive design
- Automated emergency response

## Audit Status

⚠️ **This code has not been audited.** Use at your own risk.

For production use, please:
1. Get a professional security audit
2. Run formal verification
3. Test extensively on testnets
4. Use timelocks for admin operations

## Reporting Security Issues

**Please do NOT file a public issue.**

Contact: security@example.com

Provide:
- Vulnerability description
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond within 48 hours.
