// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title ArbitrarySend
/// @notice Fee collector that accumulates protocol ETH and pays it out to a treasury.
/// @dev INTENTIONALLY VULNERABLE — unprotected function sends contract ETH to any address.
/// Reference: SWC-105 (unprotected Ether withdrawal). Same class as the many real drains where
/// a payout function shipped without access control and with a caller-chosen recipient.
contract ArbitrarySend {
    address public immutable treasury;

    event FeesSwept(address indexed to, uint256 amount);

    constructor(address _treasury) {
        treasury = _treasury;
    }

    receive() external payable {}

    // BUG: no access control and a caller-supplied recipient.
    // Intended as: only the treasury, and always to the treasury.
    function sweepFees(address payable to) external {
        uint256 amount = address(this).balance;
        emit FeesSwept(to, amount);
        to.transfer(amount);
    }
}
