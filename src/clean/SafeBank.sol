// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title SafeBank
/// @notice Minimal ETH vault: users deposit ETH and withdraw their own balance.
///         The owner can pause deposits; withdrawals always stay open.
/// @dev Checks-effects-interactions, a reentrancy lock, msg.sender authorization
///      and zero-address checks on every address input.
contract SafeBank {
    uint256 private constant _UNLOCKED = 1;
    uint256 private constant _LOCKED = 2;

    uint256 private _lock = _UNLOCKED;

    address public owner;
    bool public depositsPaused;

    mapping(address => uint256) public balanceOf;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DepositsPaused(bool paused);

    error ZeroAddress();
    error ZeroAmount();
    error NotOwner();
    error Paused();
    error InsufficientBalance(uint256 requested, uint256 available);
    error TransferFailed();
    error Reentrancy();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier nonReentrant() {
        if (_lock != _UNLOCKED) revert Reentrancy();
        _lock = _LOCKED;
        _;
        _lock = _UNLOCKED;
    }

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert ZeroAddress();
        owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    function deposit() external payable {
        if (depositsPaused) revert Paused();
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

    function setDepositsPaused(bool paused) external onlyOwner {
        depositsPaused = paused;
        emit DepositsPaused(paused);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
