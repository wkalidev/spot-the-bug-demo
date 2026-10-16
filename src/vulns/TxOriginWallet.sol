// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title TxOriginWallet
/// @notice Simple owner-controlled ETH wallet.
/// @dev INTENTIONALLY VULNERABLE — authorization via tx.origin.
/// Reference: SWC-115. If the owner interacts with a malicious contract, that contract can
/// call transferTo() and pass the check, because tx.origin is still the owner (phishing).
contract TxOriginWallet {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function transferTo(address payable to, uint256 amount) external {
        // BUG: should be msg.sender == owner.
        require(tx.origin == owner, "not owner");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "transfer failed");
    }
}
