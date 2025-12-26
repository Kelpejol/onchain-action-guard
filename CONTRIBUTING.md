# Contributing to On-Chain Action Guard

Thanks for your interest! This guide will help you contribute.

## Development Setup

### Prerequisites

- [Foundry](https://getfoundry.sh/) installed
- Git

### Installation

```bash
# Clone your fork
git clone https://github.com/your-username/on-chain-action-guard.git
cd on-chain-action-guard

# Install dependencies
forge install

# Build
forge build

# Run tests
forge test
```

## Making Changes

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Write clean, well-documented Solidity code
- Follow existing code style
- Add comprehensive tests
- Update documentation

### 3. Test Your Changes

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Check coverage
forge coverage

# Check formatting
forge fmt --check

# Generate gas report
forge test --gas-report
```

### 4. Commit

```bash
git add .
git commit -m "feat: add new feature"
```

Use conventional commit format:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `test:` Tests
- `refactor:` Code refactoring

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

## Code Style

### Solidity Guidelines

- Use Solidity 0.8.20+
- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use NatSpec comments for all public functions
- Keep functions small and focused
- Use custom errors instead of require strings

### Example

```solidity
/**
 * @notice Check if action is allowed
 * @param caller Address attempting action
 * @param amount Amount to check
 * @return bool True if allowed
 */
function check(address caller, uint256 amount) external view returns (bool) {
    if (amount > maxAmount) revert AmountTooHigh();
    return true;
}
```

## Testing Guidelines

### Writing Tests

- Test all happy paths
- Test all error cases
- Test edge cases
- Test access control
- Test gas usage

### Test Structure

```solidity
contract MyContractTest is Test {
    MyContract myContract;
    
    function setUp() public {
        myContract = new MyContract();
    }
    
    function testFeature() public {
        // Arrange
        // Act
        // Assert
    }
}
```

## Pull Request Checklist

Before submitting:

- [ ] All tests pass (`forge test`)
- [ ] Code is formatted (`forge fmt`)
- [ ] Gas report generated
- [ ] Documentation updated
- [ ] Security considerations documented
- [ ] No compiler warnings

## Security

- Think about reentrancy
- Consider flash loan attacks
- Check access control
- Validate all inputs
- Document trust assumptions

## Questions?

- Open a [Discussion](https://github.com/kelpejol/on-chain-action-guard/discussions)
- Check [Issues](https://github.com/kelpejol/on-chain-action-guard/issues)

Thank you for contributing! 🎉
