# 🛡️ On-Chain Action Guard

[![Solidity](https://img.shields.io/badge/Solidity-0.8.20-blue)](https://soliditylang.org/)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-orange)](https://getfoundry.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A minimal on-chain guard contract that enforces policy constraints before execution. Commonly used in multisigs, DAOs, and protocol risk management systems.

## 🎯 Why This Exists

Smart contract systems need **explicit policy enforcement** before executing sensitive operations:

- 💰 **Rate limiting** - Prevent excessive withdrawals
- ⏰ **Cooldown periods** - Time-based restrictions
- 🔐 **Role-based access** - Who can do what
- 📊 **Amount limits** - Maximum transaction sizes

This pattern separates **policy validation** from **execution logic**, reducing blast radius and simplifying security audits.

## ✨ Features

- 🎯 **Simple Policy Enforcement** - `ActionGuard.sol`
- 🔧 **Advanced Multi-Policy Support** - `AdvancedActionGuard.sol`
- ✍️ **Signed Approvals** - Off-chain signature verification
- 🧪 **Comprehensive Tests** - Full Foundry test suite
- 📚 **Well Documented** - Clear architecture and security model
- 🔒 **OpenZeppelin Based** - Battle-tested access control

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://getfoundry.sh/) installed

### Installation

```bash
# Clone the repo
git clone https://github.com/kelpejol/on-chain-action-guard.git
cd on-chain-action-guard

# Install dependencies
forge install

# Build contracts
forge build

# Run tests
forge test
```

### Running Tests

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testAllowsExecution

# Run with gas reporting
forge test --gas-report
```

## 📖 Contracts

### ActionGuard.sol

Simple guard with single global policy.

```solidity
// Deploy
ActionGuard guard = new ActionGuard(100 ether, 1 days);

// Check policy
guard.check(msg.sender, 10 ether); // ✅ Passes

// Record execution
guard.recordExecution(msg.sender);

// Cooldown enforced
guard.check(msg.sender, 10 ether); // ❌ Reverts
```

### AdvancedActionGuard.sol

Multi-policy support with signed approvals.

```solidity
// Set policy
bytes32 policyId = keccak256("TREASURY_WITHDRAWAL");
guard.setPolicy(caller, policyId, 100 ether, 1 days);

// Check with policy ID
guard.check(caller, policyId, 50 ether); // ✅

// Or use signed approval
guard.checkWithApproval(
    caller,
    policyId,
    50 ether,
    nonce,
    signature
);
```

### ProtectedVault.sol

Example integration showing guard usage.

```solidity
contract ProtectedVault {
    ActionGuard public guard;

    function withdraw(uint256 amount) external {
        guard.check(msg.sender, amount);
        guard.recordExecution(msg.sender);
        // ... transfer logic
    }
}
```

## 🏗️ Architecture

```
Caller
  ↓
ActionGuard (Policy Validation)
  ↓
Protected Contract (Execution)
```

### Design Principles

1. **Control Plane / Execution Plane Split** - Policy separate from logic
2. **Fail Fast** - Invalid requests rejected immediately
3. **Explicit Authorization** - No implicit trust
4. **Composability** - Works with any contract

## 🔒 Security Model

### Trust Assumptions

- `DEFAULT_ADMIN_ROLE` is trusted
- `POLICY_ADMIN_ROLE` is trusted to set valid policies
- Callers may be adversarial

### Threat Model

**Protected Against:**
- ✅ Replay attacks (nonce-based)
- ✅ Privilege escalation (role-based access)
- ✅ Policy bypass (must call guard explicitly)
- ✅ Rate limit violations (per-caller cooldowns)

**Not Protected Against:**
- ❌ Smart contract bypassing the guard entirely
- ❌ Admin key compromise
- ❌ Flash loan attacks (no economic security)

See [SECURITY.md](SECURITY.md) for complete threat model.

## 📊 Gas Usage

| Operation | Gas Cost |
|-----------|----------|
| `check()` | ~25,000 |
| `recordExecution()` | ~45,000 |
| `checkWithApproval()` | ~75,000 |

*Gas costs approximate, may vary*

## 🧪 Testing

```bash
# Run all tests
forge test

# Run with coverage
forge coverage

# Run with gas snapshots
forge snapshot

# Run specific test file
forge test --match-path test/ActionGuard.t.sol
```

### Test Structure

```
test/
├── ActionGuard.t.sol       # Basic guard tests
└── AdvancedActionGuard.t.sol  # Advanced features
```

## 🚢 Deployment

### Local Deployment

```bash
# Start local node
anvil

# Deploy (in another terminal)
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Testnet Deployment

```bash
# Deploy to Sepolia
forge script script/Deploy.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### Mainnet Deployment

```bash
# Deploy to mainnet (use hardware wallet!)
forge script script/Deploy.s.sol \
  --rpc-url $MAINNET_RPC_URL \
  --ledger \
  --broadcast \
  --verify
```

## 🔧 Configuration

### foundry.toml

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200
```

## 🤝 Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

1. Fork the repo
2. Create a branch (`git checkout -b feature/amazing`)
3. Make changes
4. Run tests (`forge test`)
5. Commit (`git commit -m 'Add feature'`)
6. Push and open PR

## 📄 License

MIT License - see [LICENSE](LICENSE) file.

## 🙏 Acknowledgments

- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Foundry](https://github.com/foundry-rs/foundry)
- Inspired by real-world DAO treasury management patterns

## 📞 Support

- 🐛 [Report Issues](https://github.com/kelpejol/on-chain-action-guard/issues)
- 💬 [Discussions](https://github.com/kelpejol/on-chain-action-guard/discussions)
- 📖 [Documentation](docs/)

## 🗺️ Roadmap

- [ ] Multi-signature requirement support
- [ ] Time-weighted voting integration
- [ ] Cross-chain policy enforcement
- [ ] Emergency pause mechanism
- [ ] Policy composition and inheritance
- [ ] Formal verification with Certora

---

**Built with ❤️ using Foundry**
