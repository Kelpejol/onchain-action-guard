// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ActionGuard.sol";

contract ActionGuardTest is Test {
    ActionGuard guard;
    address user = address(1);

    function setUp() public {
        guard = new ActionGuard(100 ether, 1 days);
        guard.grantRole(guard.EXECUTOR_ROLE(), user);
    }

    function testAllowsExecution() public {
        vm.prank(user);
        assertTrue(guard.check(user, 10 ether));
    }

    function testRejectsLargeAmount() public {
        vm.prank(user);
        vm.expectRevert(ActionGuard.AmountTooHigh.selector);
        guard.check(user, 1000 ether);
    }

    function testCooldownEnforced() public {
        vm.prank(user);
        guard.recordExecution(user);

        vm.prank(user);
        vm.expectRevert(ActionGuard.CooldownNotPassed.selector);
        guard.check(user, 10 ether);
    }
}
