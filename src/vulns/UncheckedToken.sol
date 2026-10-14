// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title UncheckedToken
/// @notice Token escrow: users deposit ERC20 tokens and withdraw them later.
/// @dev INTENTIONALLY VULNERABLE — ERC20 transfer return values are ignored.
/// Reference: tokens like ZRX or BAT return false instead of reverting on failure.
/// Integrations that ignore the bool credited users for transfers that never happened
/// (e.g. the 2018 "missing return value" incidents across several DEXes).
contract UncheckedToken {
    IERC20 public immutable token;
    mapping(address => uint256) public deposits;

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        // BUG: if transferFrom returns false, the user is credited anyway.
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        deposits[msg.sender] -= amount;
        // BUG: a silent failure here burns the user's internal balance.
        token.transfer(msg.sender, amount);
    }
}
