# On-Chain Action Guard

A minimal on-chain guard contract that enforces
policy constraints before execution.

This pattern is commonly used in multisigs,
DAOs, and protocol risk management systems.

## Architecture

Caller
  ↓
ActionGuard (policy validation)
  ↓
Protected Contract (execution)

## Guarantees

- Explicit policy enforcement
- Cooldown & rate limiting
- Role-based authorization
- Composable with other contracts

## Non-Goals

- Execution logic
- Asset custody
- Governance UI

## Design Philosophy

This guard follows a "control plane / execution plane" split.

- Control Plane: on-chain policy validation
- Execution Plane: external contracts or agents

This separation reduces blast radius and
simplifies reasoning about failures.


## Policy IDs

Policies are identified by deterministic identifiers:

bytes32 policyId = keccak256("TREASURY_WITHDRAWAL_V1");

This allows off-chain systems to reason about
policy intent without on-chain storage bloat.


## Running Tests

```bash
forge test
