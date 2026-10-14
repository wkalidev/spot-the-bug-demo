// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {SafeVault} from "../src/SafeVault.sol";

contract ReentrantReceiver {
    SafeVault public immutable vault;

    constructor(SafeVault _vault) {
        vault = _vault;
    }

    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw(msg.value);
    }

    receive() external payable {
        // Attempt to re-enter; the vault lock must make the outer call fail.
        vault.withdraw(msg.value);
    }
}

contract SafeVaultTest is Test {
    SafeVault internal vault;
    address internal alice = makeAddr("alice");

    function setUp() public {
        vault = new SafeVault();
        vm.deal(alice, 10 ether);
    }

    function test_DepositAndWithdraw() public {
        vm.startPrank(alice);
        vault.deposit{value: 3 ether}();
        assertEq(vault.balanceOf(alice), 3 ether);

        vault.withdraw(1 ether);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 2 ether);
        assertEq(alice.balance, 8 ether);
        assertEq(address(vault).balance, 2 ether);
    }

    function test_RevertWhen_WithdrawMoreThanBalance() public {
        vm.startPrank(alice);
        vault.deposit{value: 1 ether}();
        vm.expectRevert(abi.encodeWithSelector(SafeVault.InsufficientBalance.selector, 2 ether, 1 ether));
        vault.withdraw(2 ether);
        vm.stopPrank();
    }

    function test_RevertWhen_ZeroDeposit() public {
        vm.prank(alice);
        vm.expectRevert(SafeVault.ZeroAmount.selector);
        vault.deposit{value: 0}();
    }

    function test_RevertWhen_Reentering() public {
        ReentrantReceiver attacker = new ReentrantReceiver(vault);
        vm.deal(address(attacker), 1 ether);
        vm.expectRevert(SafeVault.TransferFailed.selector);
        attacker.attack{value: 1 ether}();
    }

    function testFuzz_DepositWithdraw(uint96 amount) public {
        vm.assume(amount > 0);
        vm.deal(alice, amount);
        vm.startPrank(alice);
        vault.deposit{value: amount}();
        vault.withdraw(amount);
        vm.stopPrank();
        assertEq(vault.balanceOf(alice), 0);
        assertEq(alice.balance, amount);
    }
}
