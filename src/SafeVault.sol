// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title SafeVault
/// @notice Minimal ETH vault: users deposit ETH and withdraw their own balance.
/// @dev Follows checks-effects-interactions and uses a hand-written reentrancy lock.
contract SafeVault {
    uint256 private constant _UNLOCKED = 1;
    uint256 private constant _LOCKED = 2;

    uint256 private _lock = _UNLOCKED;

    mapping(address => uint256) public balanceOf;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    error ZeroAmount();
    error InsufficientBalance(uint256 requested, uint256 available);
    error TransferFailed();
    error Reentrancy();

    modifier nonReentrant() {
        if (_lock != _UNLOCKED) revert Reentrancy();
        _lock = _LOCKED;
        _;
        _lock = _UNLOCKED;
    }

    function deposit() external payable {
        if (msg.value == 0) revert ZeroAmount();
        balanceOf[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external nonReentrant {
        // Checks
        if (amount == 0) revert ZeroAmount();
        uint256 available = balanceOf[msg.sender];
        if (amount > available) revert InsufficientBalance(amount, available);

        // Effects
        balanceOf[msg.sender] = available - amount;
        emit Withdrawn(msg.sender, amount);

        // Interactions
        (bool ok,) = msg.sender.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }
}
