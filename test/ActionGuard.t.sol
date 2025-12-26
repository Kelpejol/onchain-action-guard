// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ActionGuard.sol";

contract ActionGuardTest is Test {
    ActionGuard guard;
    address user = address(1);
    address admin = address(this);

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

    function testCooldownPassesAfterTime() public {
        vm.prank(user);
        guard.recordExecution(user);

        // Fast forward past cooldown
        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(user);
        assertTrue(guard.check(user, 10 ether));
    }

    function testUnauthorizedUserRejected() public {
        address unauthorized = address(2);
        
        vm.prank(unauthorized);
        vm.expectRevert(ActionGuard.NotAuthorized.selector);
        guard.check(unauthorized, 10 ether);
    }

    function testAdminCanUpdatePolicy() public {
        guard.updatePolicy(200 ether, 2 days);
        
        assertEq(guard.maxAmount(), 200 ether);
        assertEq(guard.cooldown(), 2 days);
    }

    function testNonAdminCannotUpdatePolicy() public {
        vm.prank(user);
        vm.expectRevert();
        guard.updatePolicy(200 ether, 2 days);
    }

    function testRecordExecutionUpdatesTimestamp() public {
        uint256 beforeTimestamp = guard.lastExecution(user);
        
        vm.prank(user);
        guard.recordExecution(user);
        
        uint256 afterTimestamp = guard.lastExecution(user);
        assertTrue(afterTimestamp > beforeTimestamp);
        assertEq(afterTimestamp, block.timestamp);
    }
}
